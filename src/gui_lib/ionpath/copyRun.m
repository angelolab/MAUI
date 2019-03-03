function [request, old_run] = copyRun(auth_token, url, old_label, copy_label)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    run_response = httpGET(auth_token, [url, '/runs/?label=', old_label]);
    old_run = run_response.Body.Data;
    if ~isempty(old_run)
        xml_path = [old_run.path, '/', old_run.xml];
        xml = download_file(auth_token, url, xml_path);
        
        new_run = struct();
        try new_run.instrument = old_run.instrument.id; catch err; disp(err); end
        try new_run.slides = old_run.slide_ids.id; catch err; disp(err); end
        try new_run.aperature = old_run.aperture.id; catch err; disp(err); end
        try new_run.label = copy_label; catch err; disp(err); end
        try new_run.magnification = old_run.magnification; catch err; disp(err); end
        try new_run.project = old_run.project.id; catch err; disp(err); end
        try new_run.description = old_run.description; catch err; disp(err); end
        try new_run.operator = old_run.operator; catch err; disp(err); end
        try new_run.user_run_date = old_run.run_date; catch err; disp(err); end
        
        files = struct();
        files.xml = {old_run.filename, xml, 'application/xml'};
        
        header = matlab.net.http.HeaderField('Content-Type', 'application/xml');
        body_struct = struct();
        body_struct.files = files;
        body_struct.data = new_run;
        body = matlab.net.http.MessageBody(body_struct);
%         run_data.update(kwargs)
%         files = {'xml': (data['filename'], buf, 'application/xml')}
% 
%         response = self.post('/runs/', data=run_data, files=files)
%         return data, response.json()

        request = matlab.net.http.RequestMessage('POST', header, body);
    end
end