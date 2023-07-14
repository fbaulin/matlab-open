classdef Iter
    %Itter Run iteratively your script
    %   Write your script. Use methods of this class to run your
    %   script multiple times with different variable sets
    % TODO: 
    % - preload support
    %   - supply starting preset through a workspace copy
    %   - splitting the script into init part & cycling part (by comment tag)
    %   - automatic for cycle placement to the postion specified by a commentary tags
    % - fixed pararmeter set mode
    % - make results optional
    % - suppression of the graphical out;
    % - custom signing of the plots: title / semi-transperent textbox / legend title
    % - grid search

    methods
        function obj = Iter()
            %ITTER Construct an instance of this class
        end

    end

    methods(Static=true)
        
        % Run the script changing variables: complete (exhaustive) permutation
        function results = run_grid(fname, var_grid, res_names, varargin)
        %run_grid Make all possible permutations of the input data
        % Supply name of your script. Define all the variables you want to 
        % change values. Only the first occurence off this variables will 
        % be substituted. Define all the results you are interested in.
        % Run this function and get the results as a table(default) or a
        % cell array.
        %
        % Args:
        %   fname       - name of your script
        %   var_grid    - name - value pairs 
        %                 ({'var1',{v11, v12, etc},'var2',{v21, v22, v23}})
        %   res_names   - names of the result variables to return ({'res1', 'res2'})
        %   
        % Keyword args (default):
        %   'TableOutput' (true)    - return the results as a table
        %                               combined with the input
        % Example:
        % % This code takes script Exp.m & runs it for all the specified
        % % combinations of variables p1,p2 (altogether 6 cases). The
        % % results are outputed as a table
        %   fname = 'Exp.m';
        %   var_grid = {'p1',{1 2 3},    'p2',{4, 5}};              % variable values you want to checkout
        %   res_names = {'result1', 'result2'};                     % names of variables in the script Exp.m you want to output
        %   results = Iter.run_grid(fname, var_grid, res_names);    % the resulting table (to get a cell array add extra arguments: 'TableOutput', false)
            table_output = Iter.get_value(varargin,'TableOutput',true);
            if ~iscell(res_names), res_names={res_names}; end
            % Create the case table 
            var_names = var_grid(1:2:end);
            var_values = var_grid(2:2:end);     % extract variable values
            % Generate all possible permutations
            combinations = cell(1, numel(var_values));
            [combinations{:}] = ndgrid(var_values{:});
            permutations = cellfun(@(x) x(:), combinations, 'UniformOutput', false);
            data_cases = cat(2, permutations{:});
            
            n_cases = size(data_cases,1);
            results = cell(n_cases, numel(res_names));
            for i = 1:n_cases
                current_case = vertcat(var_names,data_cases(i,:));
                code = Iter.replace_vars(fname,current_case(:)); 
                results(i,:) = Iter.eval_code(code, res_names);
            end
        
            if table_output
                results = horzcat(vertcat(var_names, data_cases), vertcat(res_names, results));
                results = table(results);
            end
        
        end
        
        % Run code & output the specified variables
        function result_aggregation_table = eval_code(code, list_of_variables_to_be_extracted)
            eval(code);
            result_aggregation_table = eval(['{' strjoin(list_of_variables_to_be_extracted, ',') '}']);
        end
        
        function script_content = replace_vars(script_file, r_vars)
            % Read the content of the script file
            fileID = fopen(script_file, 'r');
            script_content = fread(fileID, '*char').';
            fclose(fileID);
            
            n_vars = numel(r_vars)/2;
            % Replace variable values
            for i = 1:n_vars
                variable_name = r_vars{i*2-1};
                newValue = r_vars{i*2};
                % Construct the search pattern for the variable definition
                pattern = [variable_name '\s*=\s*[^;]*;'];
                % Construct the replacement string
                replacement = sprintf('%s = %s;', variable_name, mat2str(newValue));
                % Replace the variable definition in the script content
                script_content = regexprep(script_content, pattern, replacement,1);
            end
        
        end
        
        % поиск значения именнованного параметра по его имени
        function parameter_value = get_value(arg_in, parameter_name, varargin)
        %get_value Функция выполняет поиск имени параметра и выводит его значение
        %   Аргументы:
        %   arg_in - массив ячеек с последовательно идущими именами и значениями параметров - можно вводить varargin
        %   parameter_name - строковое значение имени параметра, значение которого требуется найти
        %   varargin - третьим элементом может быть задано значение параметра по умолчанию.
        %   KeywordArguments(varargin, 'Parameter_to_find', 69) % 69 будет присвоено, если параметра нет в varargin
            i = find(strcmpi(parameter_name,arg_in),1);
            if isempty(i)
                if nargin == 3
                    parameter_value = varargin{1};
                else 
                    error(['Параметр ' parameter_name ' не найден в вводе'])
                end
            elseif length(i)==1
                parameter_value = arg_in{i+1};    %
            else
                error(['Имя параметра ' parameter_name ' найдено несколько раз.'])
            end
        end

    end
end