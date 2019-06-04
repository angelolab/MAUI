function send_msg(recipients, subject, message, carrier)
% SEND_MSG sends email or text messages to cell phones or other mobile devices
%    assuming that you are sending from a Gmail account.
%    Text messaging is currently supported only within the US.
% 
%    RECIPIENTS is a cell array indicating the emails or phone where you 
%    wish to send the message to
%    Phone numbers can be 10-digit numbers in the format 
%    xxxxxxxxxx or xxx-xxx-xxxx or (xxx)-xxx-xxxx
%    
%    SUBJECT is a string representing the subject of the message
% 
%    MESSAGE is a string representing the body of the message
% 
%    CARRIER is your cell phone service provider, which can be one of the
%    following: 'Alltel', 'AT&T', 'Boost', 'Cingular', 'Cingular2',
%    'Cricket', 'MetroPCS', 'Nextel', 'Sprint', 'T-Mobile', 'TracFone', 
%    'USCellular', 'Verizon', or 'Virgin'. 
%    (Optional argument) If no phone numbers are provided, it does not have
%    to be specified
% 
%    EXAMPLE:
%      recipients = {'imag_email1@gmail.com', 0000000000, 'imag_email2@yahoo.com', '1111111111', '222-222-2222', '(333)-333-3333'};
%      subject    = 'Function has finished successfully';
%      message    = 'Now go out and have fun!';
%      carrier    = 'att';
%      send_msg(recipients, subject, message, carrier);
% 
%      Now if the four phone numbers above correspond to four different
%      carriers (for example, T-Mobile, Verizon, Sprint, AT&T in that order), 
%      send_msg should be called as
%      recipients = {'imag_email1@gmail.com', 0000000000, 'imag_email2@yahoo.com', '1111111111', '222-222-2222', '(333)-333-3333'};
%      subject    = 'Function has finished successfully';
%      message    = 'Now go out and have fun!';
%      carrier    = {'tmobile', 'verizon', 'sprint', 'att'};
%      send_msg(recipients, subject, message, carrier);
%
%   See also SENDMAIL.
%
% You must modify the first two lines of the code (code inside the double 
% lines) before using.
% 
% You can also send from any other account asuming that you changed
% accordingly line 145: setpref('Internet','SMTP_Server','smtp.gmail.com');
% 
% and maybe line 155: props.setProperty('mail.smtp.socketFactory.port','465');
% Other ports that might work in case 465 does not are: 25, 587, 995
% E.g., 
% props.setProperty('mail.smtp.socketFactory.port','25');
% props.setProperty('mail.smtp.socketFactory.port','587');
% props.setProperty('mail.smtp.socketFactory.port','995');
% 
% In case this function produces an error when trying to send a message,
% you might need to log into your Gmail account and loosen up the
% restrictions on the ability of 3rd parties to send emails through your
% Gmail account.
% 
% Georgios Papachristoudis Oct. 2014
% This function is an extension to the send_text_message by Ke Feng, Sept. 2007 
% Matlab Central: 
% <http://www.mathworks.com/matlabcentral/fileexchange/16649-send-text-message-to-cell-phone Send Text Message to Cell Phone>
% Please send comments to: gio.fou@gmail.com
% $Version: 1.0 $  $Date: 2014/10/17 11:46:52 $

    % =========================================================
    % YOU NEED TO TYPE IN YOUR OWN EMAIL AND PASSWORDS:
    mail = 'mibilogger@gmail.com';  %Your GMail email address
    pwd  = 'angelolab';            %Your GMail password
    % =========================================================
    
    % Find the recipients that are entered as numbers
    recipsNum = [];
    I         = cellfun(@isnumeric,recipients);    
    recipsNum = cellfun(@num2str,recipients(I),'Un',0);
    recipients(I) = [];
    
    Istr2num  = cellfun(@str2num,recipients,'Un',0);
    Istr2num  = ~cellfun(@isempty,Istr2num);
    recipsNum = [recipsNum, recipients(Istr2num)];
    recipients(Istr2num) = [];
    
    if ~isempty(recipsNum) && nargin < 4
        error('You have to provide at least one carrier since some of the recipients represent phone numbers.');
    end
    
    if nargin < 4,  carrier = [];  end
    
    if iscell(carrier) && length(carrier) ~= 1 && length(recipsNum) ~= length(carrier)
        error('If the carrier is not common across all phone numbers, you need to provide as many carriers as the phone numbers (in the respective order that these numbers appear).');
    end
    
    if ~iscell(carrier)
        tmp     = cell(size(recipsNum));
        tmp(:)  = {carrier};
        carrier = tmp;
    end
    
    if nargin==1 || isempty(subject),  subject = '';  end
    if nargin<=2 || isempty(message),  message = '';  end
    
    for i = 1:length(recipsNum)
        number = recipsNum{i};
        
        % Format the phone number to 10 digit without dashes
        number = strrep(number, '-', '');
        number = strrep(number, '(', '');
        number = strrep(number, ')', '');
        if length(number) == 11 && number(1) == '1';
            number = number(2:11);
        end
        
        % Information found from
        % http://www.sms411.net/2006/07/how-to-send-email-to-phone.html
        % http://solutions.csueastbay.edu/questions.php?questionid=348
        % and
        % http://www.wikihow.com/Email-to-a-Cell-Phone
        switch strrep(strrep(lower(carrier{i}),'-',''),'&','')
            case 'alltel';      number = strcat(number,'@message.alltel.com');
            case 'att';         number = strcat(number,'@txt.att.net');
            case 'boost';       number = strcat(number,'@myboostmobile.com');
            case 'cingular';    number = strcat(number,'@cingularme.com');
            case 'cingular2';   number = strcat(number,'@mobile.mycingular.com');
            case 'cricket';     number = strcat(number,'@sms.mycricket.com');
            case 'metropcs';    number = strcat(number,'@mymetropcs.com');
            case 'nextel';      number = strcat(number,'@messaging.nextel.com');
            case 'sprint';      number = strcat(number,'@messaging.sprintpcs.com');
            case 'tmobile';     number = strcat(number,'@tmomail.net');
            case 'tracfone';    number = strcat(number,'@mmst5@tracfone.com');
            case 'uscellular';  number = strcat(number,'@email.uscc.net');
            case 'verizon';     number = strcat(number,'@vtext.com');
            case 'virgin';      number = strcat(number,'@vmobl.com');
        end
        recipsNum{i} = number;
    end
    
    recipients = [recipients, recipsNum];
    
    %% Set up Gmail SMTP service
    % Note: following code found from
    % http://www.mathworks.com/support/solutions/data/1-3PRRDV.html
    % If you have your own SMTP server, replace it with yours.
    
    % Then this code will set up the preferences properly:
    setpref('Internet','E_mail',mail);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',mail);
    setpref('Internet','SMTP_Password',pwd);
    
    % The following four lines are necessary only if you are using GMail as
    % your SMTP server. Delete these lines if you are using your own SMTP
    % server.
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    %% Send the email
    % Send the email
    sendmail(recipients,subject,message);
    
    if strcmp(mail,'matlabsendtextmessage@gmail.com')
        disp('Please provide your own gmail for security reasons.');
        disp('You can do that by modifying the first two lines of the code');
        disp('after the bulky comments.');
    end
end