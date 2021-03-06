function c = indexable_mem(values, keys)

    assert(nargin >=1, "Not enough input arguments");
    
    if(nargin == 1 && isa(values,'function_handle'))
        func    = values;
        my_keys = zeros(1,0);
        my_vals = zeros(size(func(1),1),0);
    elseif(nargin == 1 && isvector(values))
        func    = @(is) repmat(values,1,numel(is));
        my_keys = zeros(1,0);
        my_vals = zeros(size(values,1),0);
    elseif(nargin == 2 && isa(values,'function_handle'))
        my_keys = keys;
        my_vals = values(keys);
    elseif(nargin == 2 && isvector(values) && size(values,2) == 1)
        my_keys = keys;
        my_vals = repmat(values,1,keys);
    elseif(nargin == 2 && isvector(values) && size(values,2) ~= 1)
        my_keys = keys;
        my_vals = values;
    else
        assert(false, "invalid input arguments");
    end

    c = @indexable_mem;

    function varargout = indexable_mem(keys, values)

        if(nargin == 0)
            varargout{1} = my_keys;
            varargout{2} = my_vals;
        end
        
        if(nargin == 1)
            if(numel(keys) < 500)
                loc = my_find_fasts(keys, my_keys);
            else
                [~, loc] = ismember(keys, my_keys);
            end

            v = func(keys);
            v(:,loc~=0) = my_vals(:,loc(loc~=0));

            varargout{1} = v;
        end

        if(nargin == 2)
            if(numel(keys) < 500)
                loc = my_find_fasts(keys, my_keys);
            else
                [~, loc] = ismember(keys, my_keys);
            end

            is_update = loc ~= 0;
            is_insert = loc == 0;

            if(any(is_update))
                my_vals(:,loc(is_update)) = values(:,is_update);
            end

            if(any(is_insert))
                my_keys = [my_keys keys(:,is_insert)];
                my_vals = [my_vals values(:,is_insert)];
                
                [my_keys, I] = sort(my_keys);
                [my_vals   ] = my_vals(:,I);
            end
        end
    end

    function loc = my_find_fasts(x,A)
        n_x = numel(x);
        loc = zeros(1, n_x);

        for i = 1:n_x
            loc(i) = my_find_fast(x(i),A);
        end
    end

    function loc = my_find_fast(x,A)
        L = 1;
        R = numel(A);

        if(R == 0)
            loc = 0;
            return
        end
        
        if(A(1) == x)
           loc = 1;
           return
        end

        while L+1 < R
            m = floor((L+R)/2);
            if(A(m)<x)
                L = m;
            else
                R = m;
            end
        end
        
        if(A(R) ~= x)
            loc = 0;
        else
            loc = R;
        end
    end
end