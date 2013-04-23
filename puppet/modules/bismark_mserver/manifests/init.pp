class bismark_mserver {
    if ($operatingsystem == 'Fedora' and $operatingsystemrelease == '8' and
            $puppetversion == '2.7.9') {
        include bismark_mserver::mlab_fc8
    } else {
    	if ($operatingsystem == 'CentOS' and $operatingsystemrelease == '6.3' and
        	    $puppetversion == '2.7.9') {
        	include bismark_mserver::mlab_el6
	}
	else {
        	notify { unsupported :
            	message => "Unsupported environment."
       		}
	}
   }
}
