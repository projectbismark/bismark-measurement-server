% import datetime
% def rel_date(ts):
%     td = datetime.datetime.utcnow() - datetime.datetime.utcfromtimestamp(ts)
%     if td.days > 0:
%         if td.days > 30:
%             out = datetime.datetime.utcfromtimestamp(ts).isoformat()
%         elif td.days > 1:
%             out = '%d days ago' % td.days
%         else:
%             out = '1 day ago'
%         end 
%     else:
%         if td.seconds > 60:
%             if td.seconds > 60*60:
%                 if td.seconds >= 60*60*2:
%                     out = '%d hours ago' % (td.seconds / (60*60))
%                 else:
%                     out = '1 hour ago'
%                 end
%             else:
%                 if td.seconds >= 60*2:
%                     out = '%d minutes ago' % (td.seconds / 60)
%                 else:
%                     out = '1 minute ago'
%                 end
%             end
%         else:
%             out = '%d seconds ago' % td.seconds
%         end
%     end
%     return out
% end
<html>
<head>
    <title>BISmark Measurement Servers</title>
    <link rel='stylesheet' href='/style.css'
</head>
<body>
<h1>BISmark Measurement Servers</h1>
<table>
    <tr>
        <th>FQDN</th>
        <th>IP</th>
        <th>Last seen</th>
        <th>bismark-mserver version</th>
        <th>puppet config_version</th>
    </tr>
% i = 0
% for server in mservers:
%    if i % 2 == 0:
    <tr class='row-even'>
%    else:
    <tr class='row-odd'>
%    end
        <td class='fqdn'><a rel="mserver_detail" href="{{server['fqdn']}}">{{server['fqdn']}}</a></td>
        <td class='ip'>{{server['ip']}}</td>
        <td class='lastseen'>{{rel_date(server['last_seen'])}}</td>
        <td class='version'>{{server['version']}}</td>
        <td class='pversion'><a href="https://github.com/projectbismark/bismark-measurement-server/tree/{{server['puppet_version']}}/puppet">{{server['puppet_version']}}</a></td>
    </tr>
%    i+=1
% end
</table>

<p>{{len(mservers)}} measurement servers reporting.</p>
</body>
</html>
