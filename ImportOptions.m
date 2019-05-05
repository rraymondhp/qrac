classdef (AllowedSubclasses = {?matlab.io.text.TextImportOptions,?matlab.io.spreadsheet.SpreadsheetImportOptions}) ImportOptions < matlab.io.internal.mixin.HasPropertiesAsNVPairs...
        & matlab.mixin.internal.Scalar ...
        & matlab.io.internal.shared.MissingErrorRulesInputs
    %
    
    % Copyright 2016-2018 The MathWorks, Inc.
    
    
    properties (Dependent)
        %SELECTEDVARIABLENAMES Names of variables of interest
        %   By default, SelectedVariableNames is equal to VariableNames. It can be
        %   set to any unique subset of the VariableNames to indicate which
        %   variables should be imported.
        %
        %   See also matlab.io.spreadsheet.SpreadsheetImportOptions
        SelectedVariableNames
        
        %VARIABLENAMES Names of variables
        %   The names to use when importing variables. If empty, variable names
        %   will be read from data, or generated as Var1, Var2, etc..
        %
        %   See also matlab.io.spreadsheet.SpreadsheetImportOptions
        VariableNames
        
        %VARIABLEOPTIONS Options for each import variable
        %   VariableOptions is an array of VariableImportOptions of the same size
        %   as variable names. Each element of the array sets options for a
        %   specific variable.
        %
        %   Example, setting an option for a variable by name:
        %       opts = detectImportOptions('patients.xls')
        %       opts = setvaropts(opts,'Gender','MissingRule','error');
        %
        %   See also matlab.io.spreadsheet.SpreadsheetImportOptions
        %   matlab.io.spreadsheet.SpreadsheetImportOptions/setvaropts
        %   matlab.io.spreadsheet.SpreadsheetImportOptions/getvaropts
        %   matlab.io.VariableImportOptions
        VariableOptions
        
        %VARIABLETYPES Output types of the variables
        %   VariableTypes is a cell array of character vectors whose values
        %   indicate the datatype of the variable.
        %   The following types (and resulting import variables) are supported:
        %   * char - a cell array of character vectors
        %   * double - a double precision floating point number array
        %   * single - a single precision floating point number array
        %   * datetime - a datetime array
        %   * duration - a duration array
        %   * categorical - a categorical array
        %   * int8 - an 8-bit integer array
        %   * int16 - a 16-bit integer array
        %   * int32 - a 32-bit integer array
        %   * int64 - a 64-bit integer array
        %   * uint8 - an unsigned 8-bit integer array
        %   * uint16 - an unsigned 16-bit integer array
        %   * uint32 - an unsigned 32-bit integer array
        %   * uint64 - an unsigned 64-bit integer array
        %   * logical - a logical array
        %
        %   See also matlab.io.spreadsheet.SpreadsheetImportOptions
        %   matlab.io.VariableImportOptions
        %   matlab.io.TextVariableImportOptions
        %   matlab.io.NumericVariableImportOptions
        %   matlab.io.DatetimeVariableImportOptions
        %   matlab.io.DurationVariableImportOptions
        %   matlab.io.CategoricalVariableImportOptions
        VariableTypes
    end
    
    properties (Access = private)
        var_opts = matlab.io.TextVariableImportOptions('Name','Var1');
        selected_vars = ':';
        is_unbounded_selection = true;
        using_generated_names = false;
    end
    
    properties (Hidden)
        %CREATEDBY Hidden variable to check for value of the
        %   'EmptyColumnType' field to determine what type to use when
        %   returning empty columns. For backward comptability purposes,
        %   currently we are passing in char for detectImportOptions, and
        %   double for readtable/datastore/spreadsheet.
        EmptyColumnType char
    end
    
    methods
        function obj = set.VariableTypes(obj,types)
            oldTypes = obj.VariableTypes;
            try types = cellstr(types); catch
                error(message('MATLAB:textio:textio:InvalidStringOrCellStringProperty','VariableTypes'));
            end
            if numel(types) ~= numel(oldTypes)
                error(message('MATLAB:textio:io:ExpectedCellStrSize',numel(oldTypes)))
            end
            idx = find(~strcmp(oldTypes,types));
            % Call the setType method of var_opts for only the types which need to
            % change.
            obj.var_opts = obj.var_opts.overrideType(idx,types(idx));
        end
        
        function obj = set.VariableOptions(obj,rhs)
            if ~isa(rhs,'matlab.io.VariableImportOptions') || (~isvector(rhs) && ~isempty(rhs))
                error(message('MATLAB:textio:io:ExpectedVarImportOpts'))
            end
            % replace empty names with Var##
            names = rhs.getNames;
            nOld = numel(obj.VariableOptions); nNew = numel(rhs);
            emptyIDX = find(strcmp(names,''));
            names(emptyIDX) = cellstr("Var" + (emptyIDX));
            names = matlab.lang.makeUniqueStrings(names);
            obj.var_opts = setNames(rhs(:)',names);
            if nOld ~= nNew
                obj = updatePerVarSizes(obj,nNew);
            end
            if obj.is_unbounded_selection && ~isequal(obj.selected_vars,':')
                obj.selected_vars = [obj.selected_vars nOld+1:nNew];
            end
        end
        
        function obj = set.SelectedVariableNames(obj,rhs)
            if (iscell(rhs) && ~iscellstr(rhs)) %#ok<ISCLSTR>
                error(message('MATLAB:textio:io:BadSelectionInput'));
            else
                rhs = matlab.io.internal.validators.validateCellStringInput(rhs,'Selected Variable Names');
            end
            if isnumeric(rhs)
                n = numel(obj.var_opts);
                if ~all(rhs >= 1 & rhs <= n) || ~all(floor(rhs)==rhs)
                    error(message('MATLAB:textio:io:BadNumericSelection'));
                end
            elseif ischar(rhs) || iscell(rhs)
                try rhs = cellstr(rhs);catch
                    error(message('MATLAB:textio:textio:InvalidStringOrCellStringProperty','SelectedVariableNames'));
                end
                rhs = getNumericSelection(obj,rhs);
            else
                error(message('MATLAB:textio:io:BadSelectionInput'))
            end
            obj.selected_vars = unique(rhs,'stable');
            obj.is_unbounded_selection = isequal(rhs,':');
        end
        
        function val = get.VariableNames(obj)
            val = {obj.var_opts.Name};
        end
        
        function val = get.VariableTypes(obj)
            val = {obj.var_opts.Type};
        end
        
        function val = get.VariableOptions(obj)
            val = obj.var_opts;
        end
        
        function val = get.SelectedVariableNames(obj)
            val = obj.VariableNames(:,obj.selected_vars);
        end
        
        function obj = set.VariableNames(obj,rhs)
            rhs = convertStringsToChars(rhs);
            if ischar(rhs)
                rhs = {rhs};
            end
            
            if ~iscell(rhs) || ~all(cellfun(@isvarname,rhs))
                error(message('MATLAB:textio:io:BadVariableNames'));
            end
            iscellofstrings = ~(iscellstr(rhs) || ischar(rhs) || isstring(rhs));
            if iscellofstrings
                error(message('MATLAB:makeUniqueStrings:InvalidInputStrings'));
            end
            
            rhs = rhs(:)';
            oldNames = getNames(obj.var_opts);
            nOld = numel(oldNames);
            nNew = numel(rhs);
            obj.verifyMaxVarSize(nNew);
            
            if nNew == 0
                obj.var_opts(:) = [];
            elseif nOld == 0
                rhs = matlab.lang.makeUniqueStrings(rhs,{},namelengthmax);
                obj.var_opts(:,nNew) = matlab.io.TextVariableImportOptions();
            else
                if nOld < nNew % Adding new names
                    % Make the new names unique, preserving the old names
                    obj.var_opts(:,numel(rhs)) = matlab.io.TextVariableImportOptions();
                    sameAsOldIdx = [strcmp(rhs(1:numel(oldNames)),oldNames), false(1,numel(rhs)-numel(oldNames))];
                else
                    obj.var_opts(:,1+numel(rhs):end) = [];
                    sameAsOldIdx = strcmp(rhs,oldNames(1:numel(rhs)));
                end
                % want to change the new names if they match any of the old names
                rhs = matlab.lang.makeUniqueStrings(rhs,~sameAsOldIdx);
            end
            
            if nOld ~= nNew
                obj = updatePerVarSizes(obj,nNew);
                if obj.is_unbounded_selection && ~isequal(obj.selected_vars,':')
                    obj.selected_vars = [obj.selected_vars nOld+1:nNew];
                end
                % any selected names out of range should be removed
                if ~ischar(obj.selected_vars)
                    obj.selected_vars(obj.selected_vars > nNew)=[];
                end
            end
            obj.var_opts = setNames(obj.var_opts,rhs);
        end
        
        function obj = set.NumVariables(obj,rhs)
            % Expect a non-negative scalar integer
            if ~isnumeric(rhs) || ~isscalar(rhs) || floor(rhs) ~= rhs || rhs < 0 || isinf(rhs)
                error(message('MATLAB:textio:textio:ExpectedScalarInt'));
            end
            
            obj.var_opts(rhs+1:end) = [];
            if rhs > 0
                obj.var_opts(end:rhs) = matlab.io.TextVariableImportOptions();
                % Generate VarN names with string scalar expansion
                obj.var_opts = setNames(obj.var_opts,"Var" + (1:rhs));
            end
        end
    end
    
    methods (Abstract, Access = protected)
        obj = updatePerVarSizes(obj,nNew);
        addCustomPropertyGroups(opts,helper);
        modifyCustomGroups(opts,helper);
        verifyMaxVarSize(obj,n);
    end
    
    methods % class functions
        function opts = setvartype(opts,varargin)
            %setvartype
            %   OPTS = setvartype(OPTS,TYPE) set all variables to the
            %          specified TYPE by name.
            %
            %   OPTS = setvartype(OPTS,NAMES,TYPE) set the variables to the
            %          specified TYPE by name. NAMES can be a character vector or a
            %          cell array of character vectors.
            %
            %   OPTS = setvartype(OPTS,INDEX,TYPE) set the variables to the
            %          specified TYPE by index. INDEX must be a vector of positive integers with
            %          values between 1 and the length of the VARIABLENAMES property of OPTS.
            %
            %          TYPE can be any numeric type, 'string, 'char',
            %          'datetime', 'duration, 'categorical' or 'logical'.
            %
            %   See also
            %   setvaropts, getvaropts, detectImportOptions
            %   matlab.io.VariableImportOptions
            
            import matlab.io.internal.validators.validateCellStringInput;
            
            narginchk(2,3);
            if nargout == 0
                error(message('MATLAB:textio:io:NOLHS','setvartype','setvartype'))
            end
            v_opts = opts.var_opts;
            if nargin == 2
                % setvartype(OPTS,TYPE) syntax
                selection = 1:numel(v_opts);
                type = varargin{1};
            elseif isnumeric(varargin{1})
                selection = varargin{1};
                type = varargin{2};
            elseif islogical(varargin{1})
                selection = find(varargin{1});
                type = varargin{2};
            else
                selection = validateCellStringInput(convertStringsToChars(varargin{1}), 'SELECTION');
                if iscell(selection) || ischar(selection)
                    % Get the appropriate numeric indices and error for unknown variable names.
                    selection = opts.getNumericSelection(selection);
                end
                type = convertStringsToChars(varargin{2});
            end
            % Convert to cellstr
            try type = cellstr(type); catch
                error(message('MATLAB:textio:textio:InvalidStringOrCellStringProperty','TYPES'));
            end
            
            % Expand scalar
            if isscalar(type)
                type = repmat(type,size(selection));
            elseif numel(type) ~= numel(selection)
                error(message('MATLAB:textio:io:MismatchVarTypes'))
            end
            
            % Set the underlying types
            try
                opts.var_opts = v_opts.overrideType(selection,type);
            catch ME
                throw(ME)
            end
        end
        
        function opts = setvaropts(opts,varargin)
            %setvaropts
            %   OPTS = setvaropts(OPTS,VARNAMES, ...) set the options of variables
            %          by name. VARNAMES can be a character vector or a cell array of
            %          character vectors containing variable names.
            %
            %   OPTS = setvaropts(OPTS,INDEX,...) set the options of variables by index. INDEX
            %          must be a vector of positive integers with values between 1
            %          and the length of the VARIABLENAMES property of OPTS.
            %
            %   OPTS = setvaropts(OPTS,...) set all variables to the options specified. NOTE: If
            %          the VARIABLETYPES property of OPTS list different types for different
            %          variables, only the options which are available for all types can be
            %          specified. If all the VARIABLETYPES of OPTS are the same, then the type
            %          specific options may be specified.
            %
            %   OPTS = setvaropts(___,OPTION1,VALUE1,...,OPTIONK,VALUEK) set the selected options
            %          with the parameters OPTION1, ..., PARAMK, to VALUE1, ..., VALUEK respectively.
            %          NOTE: If the selection of variables have different types, only the options
            %          which are available for all types can be specified. If all the variable
            %          types of the variables are the same, then the type specific options may be
            %          specified.
            %
            %   Valid parameter names available for all variable types are:
            %       FillValue          - A scalar value to fill missing or
            %                            unconvertible data
            %       TreatAsMissing     - Text which is used in a file to represent
            %                            missing data, e.g. 'NA'
            %       QuoteRule          - How to treat quoted text.
            %       Prefixes           - Prefix characters to be removed
            %                            from variable on import
            %       Suffixes           - Suffix characters to be removed
            %                            from variable on import
            %
            %   Numeric specific options:
            %       ExponentCharacter  - Character which should be treated as exponents when
            %                            converting text
            %       DecimalSeparator   - Character used to separate the integer part of a
            %                            number from the decimal part of the number
            %       ThousandsSeparator - Character used to separate the thousands place
            %                            digits
            %       TrimNonNumeric     - Logical used to specify that all
            %                            prefixes and suffixes must be removed
            %
            %   Text specific options:
            %       WhitespaceRule     - How to treat whitespace surrounding text
            %
            %   Datetime specific options:
            %     DatetimeFormat       - Output format of the datetime array.
            %        InputFormat       - The format to use when importing
            %                            text as dates
            %     DatetimeLocale       - The locale to be used when importing text as
            %                            dates
            %
            %   Duration specific options:
            %     DurationFormat       - Output format of the duration array.
            %        InputFormat       - The format to use when importing text as
            %                            time
            %     FieldSeparator       - The character used to separate
            %                            fields in the duration text
            %   DecimalSeparator       - Character used to separate the integer part of a
            %                            number from the decimal part of
            %                            the number; applies to the seconds
            %                            field of the duration text
            %
            %   Categorical specific options:
            %         Categories       - List of expected categories
            %          Protected       - Whether the output array is protected
            %            Ordinal       - Whether the output array is ordinal
            %
            %   Logical specific options:
            %        TrueSymbols       - Text to be converted to the logical value
            %                            true.
            %       FalseSymbols       - Text to be converted to the logical value
            %                            false.
            %      CaseSensitive       - Whether or not to consider case when matching
            %                            symbols
            %
            %   Note: Certain variable import options control how text data (either in
            %   text files or spreadsheet files) are converted to their respective
            %   types. Native spreadsheet types which are converted to MATLAB types do
            %   not use these options. For example, dates in spreadsheet files are stored as a
            %   number of days since January 1st 1900, thus the InputFormat will not be
            %   considered. However, dates ealier than January 1st 1900 must be stored in
            %   spreadsheet files as text, and thus be converted using the value of InputFormat.
            %
            %   See also
            %   setvartype, getvaropts, detectImportOptions, matlab.io.VariableImportOptions
            
            % Check the inputs for evenly matched N-V paris.
            
            narginchk(2,inf);
            if nargout == 0
                error(message('MATLAB:textio:io:NOLHS','setvaropts','setvaropts'))
            end
            
            func = matlab.io.internal.functions.FunctionStore.getFunctionByName('setvaropts');
            opts = func.validateAndExecute(opts,varargin{:});
        end
        
        function vopts = getvaropts(opts,selection)
            %getvaropts get variable options by name or number
            %   VOPTS = getvaropts(OPTS,NAMES) get the options for the variables
            %           with specified names. NAMES can be a character vector or cell
            %           array of character vectors.
            %
            %   VOPTS = getvaropts(OPTS,INDEX) get the options for the variables
            %           in the specified index. INDEX must be a vector of positive integers with
            %           values between 1 and the length of the VARIABLENAMES property of OPTS.
            %
            %   VOPTS = getvaropts(OPTS) get the options for ALL the variables
            %
            %   See also
            %   setvaropts, setvartype, detectImportOptions, matlab.io.VariableImportOptions
            
            if ~exist('selection','var')
                selection = ':';
            end
            selection = matlab.io.internal.validators.validateCellStringInput(selection, 'NAMES');
            vopts = opts.var_opts(opts.fixSelection(selection));
        end
        
    end
    
    methods (Access = private)
        function idx = getNumericSelection(obj,selection)
            selection = cellstr(selection);
            if isscalar(selection) && strcmp(selection,':')
                idx = 1:numel(obj.var_opts);
            else
                [~,idx] = ismember(selection,{obj.var_opts.Name});
                if any(idx==0)
                    error(message('MATLAB:textio:io:UnknownVarName',selection{find(idx==0,1)}));
                end
            end
        end
        
        function selection = fixSelection(opts,selection)
            if iscell(selection) || ischar(selection)
                selection = opts.getNumericSelection(selection);
            elseif isnumeric(selection)
                if ~all(selection > 0 & isfinite(selection) & floor(selection)==selection & selection <= numel(opts.var_opts))
                    error(message('MATLAB:textio:io:BadNumericSelection'));
                end
            else
                error(message('MATLAB:textio:io:BadSelectionInput'));
            end
        end
    end
    methods (Static, Hidden)
        function [filename,opts,rrn,rvn,args] = validateReadtableInputs(filename,opts,args)
            persistent parser
            filename = matlab.io.internal.validators.validateFileName(filename);
            % Choose the first match from the list of valid file names.
            filename = filename{1};
            if ~isa(opts,'matlab.io.ImportOptions')
                error(message('MATLAB:textio:io:OptsSecondArg'))
            end
            if isempty(parser)
                parser = inputParser();
                parser.FunctionName = 'readtable';
                parser.KeepUnmatched = true;
                parser.addParameter('ReadVariableNames',false,@(tf)validateLogical(tf,'ReadVariableNames'));
                parser.addParameter('ReadRowNames',false,@(tf)validateLogical(tf,'ReadRowNames'));
            end
            [args{:}] = convertStringsToChars(args{:});
            parser.parse(args{:});
            params = parser.Results;
            
            rrn = params.ReadRowNames;
            if rrn && ~opts.usingRowNames()
                % User didn't define a rownamesColumn, but called readtable with ReadRowNames
                opts = opts.setRowNames(true);
            elseif ~rrn && ~any(strcmp('ReadRowNames',parser.UsingDefaults)) && opts.usingRowNames()
                % User specified a RowNamesColumn, but asked readtable not to import it.
                % set the RowNames back to default
                opts = opts.setRowNames(false);
            end
            
            rvn = params.ReadVariableNames;
            
        end
    end
    
    methods (Hidden)
        
        function T  = readtable(filename,opts,varargin)
            if ~isa(opts,'matlab.io.ImportOptions')
                error(message('MATLAB:textio:io:OptsSecondArg','readtable'))
            end
            try
                func = matlab.io.internal.functions.FunctionStore.getFunctionByName('readtableWithImportOptions');
                T = func.validateAndExecute(filename,opts,varargin{:});
            catch ME
                throw(ME);
            end
        end
        
        function TT = readtimetable(filename,opts,varargin)
            if ~isa(opts,'matlab.io.ImportOptions')
                error(message('MATLAB:textio:io:OptsSecondArg','readtimetable'))
            end
            try
                func = matlab.io.internal.functions.FunctionStore.getFunctionByName('readtimetableWithImportOptions');
                TT = func.validateAndExecute(filename,opts,varargin{:});
            catch ME
                throw(ME);
            end
        end
        
        function A = readmatrix(filename,opts,varargin)
            if ~isa(opts,'matlab.io.ImportOptions')
                error(message('MATLAB:textio:io:OptsSecondArg','readmatrix'))
            end
            try
                func = matlab.io.internal.functions.FunctionStore.getFunctionByName('readmatrixWithImportOptions');
                A = func.validateAndExecute(filename,opts,varargin{:});
            catch ME
                throw(ME);
            end
        end
        
        function C = readcell(filename,opts,varargin)
            if ~isa(opts,'matlab.io.ImportOptions')
                error(message('MATLAB:textio:io:OptsSecondArg','readcell'))
            end
            try
                func = matlab.io.internal.functions.FunctionStore.getFunctionByName('readcellWithImportOptions');
                C = func.validateAndExecute(filename,opts,varargin{:});
            catch ME
                throw(ME);
            end
        end
        
        function varargout = readvars(filename,opts,varargin)
            if ~isa(opts,'matlab.io.ImportOptions')
                error(message('MATLAB:textio:io:OptsSecondArg','readvars'))
            end
            try
                func = matlab.io.internal.functions.FunctionStore.getFunctionByName('readvarsWithImportOptions');
                [varargout{1:nargout}] = func.validateAndExecute(filename,opts,varargin{:});
            catch ME
                throw(ME);
            end
        end
        
        function disp(opts)
            import matlab.io.internal.cellArrayDisp;
            name = inputname(1);
            h = matlab.internal.datatypes.DisplayHelper(class(opts));
            
            opts.addCustomPropertyGroups(h);
            
            replacePropDisp(h,"VariableNames",cellArrayDisp(opts.VariableNames,false,''));
            replacePropDisp(h,"VariableTypes",cellArrayDisp(opts.VariableTypes,false,''));
            replacePropDisp(h,"SelectedVariableNames",cellArrayDisp(opts.SelectedVariableNames,false,''));
            
            if h.usingHotlinks()
                setVarHelp = h.helpTextLink("setvaropts", class(opts) + "/setvaropts");
                getVarHelp = h.helpTextLink("getvaropts", class(opts) + "/getvaropts");
                setvartypeText = h.helpTextLink("setvartype", class(opts) + "/setvartype");
                
                replacePropDisp(h,"VariableOptions",...
                    sprintf('Show all %d %s',numel(opts.VariableOptions),h.propDisplayLink(name,"VariableOptions")));
            else
                setVarHelp = "setvaropts";
                getVarHelp = "getvaropts";
                setvartypeText = "setvartype";
            end
            
            appendPropDisp(h,"VariableOptions",...
                sprintf("\n\tAccess VariableOptions sub-properties using %s/%s",setVarHelp,getVarHelp));
            if h.usingHotlinks()
                previewHelp = h.helpTextLink("preview","matlab.io.text.TextImportOptions/preview");
            else
                previewHelp = "preview";
            end
            
            if isa(opts,'matlab.io.spreadsheet.SpreadsheetImportOptions')
                dispProp = "VariableDescriptionsRange";
            else
                dispProp = "VariableDescriptionsLine";
            end
            appendPropDisp(h,dispProp,sprintf('\n\t%s %s',...
                getString(message('MATLAB:textio:io:TablePreview')),previewHelp));
            opts.modifyCustomGroups(h);
            appendPropDisp(h,"Variable Import Properties",sprintf("Set types by name using " + setvartypeText));
            h.printToScreen("opts",false);
        end
    end
    
    properties (Dependent, Access = {?matlab.io.internal.mixin.HasPropertiesAsNVPairs})
        NumVariables
    end
    
    methods (Hidden)
        function opts = setUnboundedSelection(opts,isUnbounded)
            opts.is_unbounded_selection = isUnbounded;
        end
        function tf = namesAreGenerated(opts)
            tf = opts.using_generated_names;
        end
        function opts = useGeneratedNames(opts,rnc)
            opts.using_generated_names = true;
            idx = 1:numel(opts.var_opts);
            names = compose('Var%d',idx);
            if rnc > 0
                names{end} = 'Row';
                names([rnc rnc+1:end]) = names([end rnc:end-1]);
            end
            
            opts.var_opts.setNames(names);
        end
    end
end



function validateLogical(tf,param)
if ~islogical(tf) && ~isnumeric(tf) || ~isscalar(tf)
    error(message('MATLAB:table:InvalidLogicalVal',param));
end
end
% LocalWords:  IMPORTERRORRULE omitrow omitvar MISSINGRULE
% LocalWords:  SELECTEDVARIABLENAMES VARIABLENAMES VARIABLEOPTIONS setvaropts
% LocalWords:  getvaropts VARIABLETYPES XFD importoptions setvartype NOLHS
% LocalWords:  paris nv newnames VOPTS
