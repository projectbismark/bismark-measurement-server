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
%     else:
%         if td.seconds > 60:
%             if td.seconds > 60*60:
%                 if td.seconds >= 60*60*2:
%                     out = 'd% hours ago' % (td.seconds / (60*60))
%                 else:
%                     out = '1 hour ago'
%             else:
%                 if td.seconds >= 60*2:
%                     out = '%d minutes ago' % td.seconds / 60
%                 else:
%                     out = '1 minute ago'
%         else:
%             out = '%d seconds ago' % td.seconds
% end
<html>
<head>
    <title>BISmark Measurement Server Status</title>
</head>
<body>
<table>
    <tr>
        <th>FQDN</th>
        <th>IP</th>
        <th>Last seen</th>
        <th>bismark-mserver version</th>
        <th>puppet config_version</th>
    </tr>
% for server in mservers:
    <tr>
        <td><a rel="mserver_detail" href="{{server['fqdn']}}">{{server['fqdn']}}</a></td>
        <td>{{server['ip']}}</td>
        <td>{{rel_time(server['last_seen'])}}</td>
        <td>{{server['version']}}</td>
        <td>{{server['puppet_version']}}</td>
    </tr>
% end
</table>

<p>{{len(mservers)}} measurement servers reporting.</p>
</body>
</html>
