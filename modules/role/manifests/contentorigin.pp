# @summary content origin server
class role::contentorigin {
  include profile::base
  include profile::certbot
  include profile::contentorigin
}
