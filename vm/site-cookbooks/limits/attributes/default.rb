# make this a list of the additional limits to apply
#  {"limits": { "limits": [ ["httpd", "soft", "nofile", "4096"] ] }}
#  {"limits": { "limits": [ ["*", "soft", "nofile", "4096"] ] }}
default['limits']['limits'] = nil
default['limits']['limits.conf'] = '/etc/security/limits.conf'

