function [response] = uploadTIFF(auth_token, url, filepath)
    % filepath needs to be a path to a properly-formatted multipage TIFF
    url_response = httpGET(auth_token, [url, '/upload_mibitiff/sign_tiff_url/']);
    % we're going to use url_response.Body.Data.url
    url = url_response.Body.Data.url;
    fid = fopen(filepath, 'r');
    data = char(fread(fid)');
    header = matlab.net.http.HeaderField('Content-Type', 'image/tiff');
    
    body = matlab.net.http.MessageBody(data);
    request = matlab.net.http.RequestMessage('PUT', header, body);
    [response,completedrequest,history] = send(request,url);
    
    % we need the url
    % we nedd the data
    % we need the header
    
%     py.importlib.import_module('requests');
%     file = py.open(filepath, 'rb');
%     
%     files = py.dict();
%     [~, filepath, ~] = fileparts(filepath);
%     files{'tiff'} = py.tuple({[filepath, '.tiff'], file, 'image/tiff'});
%     
%     headers = py.dict();
%     format = py.str('JWT {}');
%     headers{'Authorization'} = format.format(auth_token);
%     
%     data = py.dict();
%     data{'run'} = py.int(runID);
%     
%     try
%         response = py.requests.post([url, '/upload_tiff/'], pyargs('data', data, 'files', files, 'headers', headers));
%         response.raise_for_status();
%     catch e
%         response = e;
%     end
end