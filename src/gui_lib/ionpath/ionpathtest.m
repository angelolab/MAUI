setenv('PATH', '/anaconda3/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin');

url = 'https://backend-dot-mibitracker-angelolab.appspot.com';
usr = {'alex.baranski@gmail.com', '9g4VzcEb}dvwTa+iLPqaHu%QoMJ9D@7g'};

if exist('auth_token')
    auth_token = getToken(url, usr, auth_token);
else
    auth_token = getToken(url, usr);
end

[status, cmdout] = GET(url, auth_token, '/panels/');
panels = json.load(cmdout);

%% 

function auth_token = getToken(url, usr, varargin)
    email = usr{1}; password = usr{2};
    if numel(varargin)==1 % a token was provided, check the token
        auth_token = varargin{1};
        [status, cmdout] = system(['python3 ', script(), ' -auth ', url, ' ', auth_token]);
        if ~isempty(cmdout)
            auth_token = getAuthToken(url, email, password);
        end
    else
        auth_token = getAuthToken(url, email, password);
    end
end

function [status, cmdout] = GET(url, token, route)
    [status, cmdout] = system(['python3 ', script(), ' -auth ', url, ' ', token, ' -get ', route]);
end

function val = script()
    val = '/Users/raymondbaranski/GitHub/MIBI_GUI/gui_lib/ionpath/mibitracker-client-master/mibitracker/ionpath_test.py';
end