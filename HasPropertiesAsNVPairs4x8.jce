classdef (HandleCompatible,Abstract) HasPropertiesAsNVPairs
    %

    % Copyright 2016-2018 The MathWorks, Inc.
    methods (Access = protected)
        function [obj, otherArgs] = parseInputs(obj,argsIn,priority)
        p = getParserByClass(class(obj));
        if iscell(argsIn)
            p.parse(argsIn{:});
        else % must be a struct.
            p.parse(argsIn);
        end
        
        % Deal the results to the converter.
        results  = p.Results;
        defaults = string(p.UsingDefaults);
        if exist('priority','var')
            % Inputs are assigned in the order they appear in the argument list.
            % To change this order, move any proprties which may have dependencies to
            % the beginning of the list.
            names = setdiff(p.Parameters,defaults);
            for i = numel(priority):-1:1
                tomove = strcmpi(names,priority(i));
                names = [names(tomove) names(~tomove)];
            end
        else 
            names = p.Parameters;
        end

        for param = names
            % only set the ones given by the user.
            if ~any(param==defaults)
                try
                    obj.(param{:}) = results.(param{:});
                catch ME
                    throwAsCaller(ME)
                end
            end
        end
        otherArgs = p.Unmatched;
        end
        
        function assertNoAdditionalParameters(~,fieldNames,name)
        if ~isempty(fieldNames)
            error(message('MATLAB:InputParser:UnmatchedParameter',...
                fieldNames{1},...
                getString(message('MATLAB:InputParser:ValidParameters',name))));
        end
        end
        
    end
    
end

% This creates a collection of parsers so the inputParser is
% generated only once per class
function p = getParserByClass(classname)
persistent map baseParser

if isempty(map)
    map = containers.Map('KeyType','char','ValueType','any');
    baseParser = inputParser;
    baseParser.PartialMatching = false;
    baseParser.CaseSensitive = false;
    baseParser.KeepUnmatched = true;
    baseParser.StructExpand = true;
end

if map.isKey(classname)
    p = map(classname);
else
    % create custom parser for this class
    newParser = baseParser.copy();
    newParser.FunctionName = classname;
    % get public properties
    props = unique(properties(classname))';
    
    % Add accessable properties given access by this mixin class
    % This treats properties as NV pairs that might otherwise not be settable
    % through the public interface.
    me = meta.class.fromName(classname);
    access = {me.PropertyList(:).GetAccess};
    for i = 1:numel(access)
        accessList = access{i};
        if iscell(accessList) && any(strcmp('matlab.io.internal.mixin.HasPropertiesAsNVPairs',{accessList{:}.Name}))
            props{end+1} = me.PropertyList(i).Name; %#ok<AGROW>
        end
    end
    
    for p = props
        newParser.addParameter(p{:},[]);
    end
    map(classname) = newParser;
    p = newParser;
end

end
