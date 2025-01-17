# @summary provisions a single user account
# @param $ensure present or absent.
# @param $uid The numeric UID of this user.
# @param $key_type "ssh-rsa", "ssh-ed25519", or something else.
# @param $key SSH public key.
# @param $groups ignored
# @param $user_groups the groups this user is in
# @param $root If true, add the user to the `sudo` group, and add their key to the `root` user.
define users::account (
  Jqlib::Ensure $ensure,
  Integer       $uid,
  String        $key_type,
  String        $key,
  Array[String] $user_groups,
  Array[String] $groups,
  Boolean       $root,
) {
  if $root {
    # adm for viewing logs and similar without sudo
    $adm_group = ['adm']
  } else {
    $adm_group = []
  }

  group { $title:
    ensure => $ensure,
    gid    => $uid,
  }

  user { $title:
    ensure         => $ensure,
    uid            => $uid,
    gid            => $uid,
    password       => '*',
    managehome     => true,
    purge_ssh_keys => true,
    groups         => $user_groups + $adm_group,
    home           => "/home/${title}",
    shell          => '/bin/bash',
  }

  if $ensure == 'present' {
    file { "/home/${title}":
      ensure       => directory,
      source       => [
        "puppet:///modules/users/home/${name}/",
        'puppet:///modules/users/home/skel/',
      ],
      sourceselect => 'first',
      recurse      => 'remote',
      mode         => '0664',
      owner        => $title,
      group        => $title,
      force        => true,
    }
  }

  ssh_authorized_key { "${title}_key":
    ensure => $ensure,
    user   => $title,
    type   => $key_type,
    key    => $key,
  }

  if $root {
    ssh_authorized_key { "root_${title}_key":
      ensure => $ensure,
      user   => 'root',
      type   => $key_type,
      key    => $key,
    }
  }
}
