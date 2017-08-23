%% @author Marc Worrell <marc@worrell.nl>
%% @copyright 2017 Marc Worrell
%% @doc Use GitHub for logon
%%
%% Setup instructions:
%% * Enable the mod_github module
%% * Configure in the admin the GitHub keys (Auth -> External Services)

%% Copyright 2014 Marc Worrell
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(mod_github).
-author("Marc Worrell <marc@worrell.nl>").

-mod_title("GitHub").
-mod_description("Use GitHub for logon.").
-mod_prio(500).
-mod_depends([admin, authentication]).
-mod_provides([github]).

%% interface functions
-export([
        event/2,
        get_config/1
    ]).

-define(GITHUB_SCOPE, "user:email").

-include_lib("zotonic.hrl").


event(#submit{message=admin_github}, Context) ->
    case z_acl:is_allowed(use, mod_admin_config, Context) of
        true ->
            save_settings(Context),
            z_render:growl(?__("Saved the GitHub settings.", Context), Context);
        false ->
            z_render:growl(?__("You don't have permission to change the GitHub settings.", Context), Context)
    end.

save_settings(Context) ->
    lists:foreach(fun ({Key, Value}) ->
                        K1 = z_convert:to_list(Key),
                        case is_setting(K1) of
                            true -> m_config:set_value(mod_github, list_to_atom(K1), Value, Context);
                            false -> ok
                        end
                  end,
                  z_context:get_q_all_noz(Context)).

is_setting("appid") -> true;
is_setting("appsecret") -> true;
is_setting("useauth") -> true;
is_setting(_) -> false.


%% @doc Return the linkedin appid, secret and scope
-spec get_config(#context{}) -> {AppId::string(), Secret::string(), Scope::string()}.
get_config(Context) ->
    { z_convert:to_list(m_config:get_value(mod_github, appid, Context)),
      z_convert:to_list(m_config:get_value(mod_github, appsecret, Context)),
      ?GITHUB_SCOPE
    }.
