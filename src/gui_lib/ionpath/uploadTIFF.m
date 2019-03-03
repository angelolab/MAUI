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
end