function [ varargout ] = param_optimize( varargin )
%Parameter optimization across ML methods:
%   intelligently tries combinations of ML methods on data to
%   get the best predictions on some dataset


%% -- not currently operational -- needs further specification

classifer = varargin{1}; %ensemble, ensembleADA, dbn, nn, libsvm, or svm
    switch lower(classifier)
        case {'ensemble'}
            params = varargin{2:10};
            subclassifier = varargin{11}; %dbn, nn, libsvm, or svm
        switch lower(subclassifier)
            case {'dbn'}
                subparams = varargin{12:18};
            case {'nn'}
                subparams = varargin{12:17};
            case {'libsvm'}
                subparams = varargin{12:15};
            case {'svm'}
                subparams = varargin{12:14};
            otherwise
                disp('invalid subclassifier')
        end
        
        case {'ensembleADA'}
            params = varargin{2:10};
            subclassifier = varargin{11}; %dbn, nn, libsvm, or svm
        switch {subclassifier}
            case {'dbn'}
                subparams = varargin{12:18};
            case {'nn'}
                subparams = varargin{12:17};
            case {'libsvm'}
                subparams = varargin{12:15};
            case {'svm'}
                subparams = varargin{12:14};
            otherwise
                disp('invalid subclassifier')
        end
        
    case {'dbn'}
        params = varargin{2:8};
    case {'nn'}
        params = varargin{2:7};
    case {'libsvm'}
        params = varargin{2:5};
    case {'svm'}
        params = varargin{2:4};
    otherwise
        disp('invalid subclassifier')
    end       
        






varargout = result;
end

