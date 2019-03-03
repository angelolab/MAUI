function [data] = download_file(auth_token, url, path)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
    response = httpGET(auth_token, [url, '/download/?path=', path]);
    data = urlread(response.Body.Data.url);
end