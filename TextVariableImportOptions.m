classdef TextVariableImportOptions < matlab.io.VariableImportOptions ...
        & matlab.io.internal.shared.TextVarOptsInputs
    %TEXTVARIABLEIMPORTOPTIONS options for importing text variables
    %   topts = matlab.io.TextVariableImportOptions(...)
    %
    %   TextVariableImportOptions properties:
    %               Name - The name of the variable on import
    %               Type - The data type of the variable on import
    %          FillValue - A scalar value to fill missing or unconvertible data
    %     TreatAsMissing - Text which is used in a file to represent missing
    %                      data, e.g. 'NA'
    %          QuoteRule - How to treat quoted text
    %     WhitespaceRule - How to treat whitespace surrounding text
    %
    %   See also matlab.io.VariableImportOptions
    
    % Copyright 2016-2018 The MathWorks, Inc.
    
    methods
        function obj = TextVariableImportOptions(varargin)
            %TextVariableImportOptions options for importing text variables.
            [obj,otherArgs] = obj.parseInputs(varargin);
            obj.assertNoAdditionalParameters(fields(otherArgs),class(obj));
        end
    end
    
    methods (Access = protected)
        function [type_specific,group_name] = getTypedPropertyGroup(obj)
            group_name = 'String Options:';
            type_specific.WhitespaceRule = obj.WhitespaceRule;
        end
        
        function tf = compareVarProps(a,b)
            tf = isequaln(a.FillValue,b.FillValue)...
                && strcmp(a.WhitespaceRule,b.WhitespaceRule);
            
        end
    end
    
    methods (Sealed,Hidden)
        function [var,errid,placeholder] = readSpreadsheetVariable(varopts,sheet,subrange,typeIDs)
            if strcmp(varopts.Type, 'string')
                treatAsMissingVals = string(varopts.TreatAsMissing);
                % Create an empty vector to hold our results
                var = strings(size(typeIDs));
            else
                treatAsMissingVals = varopts.TreatAsMissing;
                % Create an empty vector to hold our results
                var = repmat({''},size(typeIDs));
            end
            
            % Initialize errid logical vector
            errid = false(size(typeIDs));
            placeholder = errid;
            textmask = typeIDs == sheet.STRING;
            if any(textmask(:))
                data = sheet.readStrings(subrange,varopts.Type);
                if ~isempty(treatAsMissingVals)
                    placeholder(ismember(strip(data),treatAsMissingVals)) = true;
                end
                var(textmask) = data(textmask);
            else
                placeholder = false(size(typeIDs));
            end
            
            datemask = typeIDs == sheet.DATETIME;
            if any(datemask(:))
                complexRepDates = sheet.readDates(subrange);
                dates = matlab.io.spreadsheet.internal.createDatetime(complexRepDates(datemask), 'default', '');
                var(datemask) = cellstr(dates, [], 'system');
            end
            
            boolmask = typeIDs == sheet.BOOLEAN;
            if any(boolmask(:))
                % Convert to 'true' and 'false'
                values = {'true'; 'false'};
                data = sheet.readBooleans(subrange);
                var(boolmask) = values(2 - data(boolmask),:);
            end
            
            numbermask = typeIDs == sheet.NUMBER;
            if any(numbermask(:))
                data = sheet.readNumbers(subrange);
                data(~numbermask) = [];
                strdata = num2str(data(:));
                var(numbermask) = strtrim(cellstr(strdata));
            end
            
            switch varopts.WhitespaceRule
                case 'trim'
                    var = strip(var,'both');
                case 'trimleading'
                    var = strip(var,'left');
                case 'trimtrailing'
                    var = strip(var,'right');
                case 'preserve'
                    % Do nothing
            end
            var(textmask) = varopts.handleQuotes(var(textmask));
            if ~isempty(varopts.Prefixes) || ~isempty(varopts.Suffixes)
                import matlab.io.internal.utility.removePrefixSuffix
                var(textmask) = removePrefixSuffix(var(textmask),varopts.Prefixes,varopts.Suffixes);
            end
        end
    end
end

