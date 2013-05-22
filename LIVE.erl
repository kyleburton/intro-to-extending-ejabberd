% Show Audium
% join 'testroom'

% run/expand 'erlnode'
nodes().
net_adm:ping(ejabberd@ejabberd01).
nodes().

l(mod_restful_debug).
mod_restful_debug:show_keys().
mod_restful_debug:save(foo,"This is a thing.").
mod_restful_debug:lookup(foo).
mod_restful_debug:show_keys().

% open mod_restful_debug.erl and introduce 'delete'
%   rake build

l(mod_restful_debug).
mod_restful_debug:delete(foo).
mod_restful_debug:show_keys().

% open mod_restful_admin.erl show process_rest, inject the parameter capture
%   rake build
l(mod_restful_admin).
% run a curl command / GET
mod_restful_debug:show_keys().
mod_restful_debug:get(get_args).
mod_restful_debug:get(post_args).

% get the cookie
erlang:get_cookie().

% codepath
code:get_path().

% see first 10 parts of the path
lists:sublist(code:get_path(),10).
