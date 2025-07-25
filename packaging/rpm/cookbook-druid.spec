Name: cookbook-druid
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: Druid cookbook to install and configure it in redborder environments

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-druid
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build

%install
mkdir -p %{buildroot}/var/chef/cookbooks/druid
cp -f -r  resources/* %{buildroot}/var/chef/cookbooks/druid
chmod -R 0755 %{buildroot}/var/chef/cookbooks/druid
install -D -m 0644 README.md %{buildroot}/var/chef/cookbooks/druid/README.md

%pre
if [ -d /var/chef/cookbooks/druid ]; then
    rm -rf /var/chef/cookbooks/druid
fi

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload druid'
  ;;
esac

%postun
# Deletes directory when uninstall the package
if [ "$1" = 0 ] && [ -d /var/chef/cookbooks/druid ]; then
  rm -rf /var/chef/cookbooks/druid
fi

%files
%defattr(0644,root,root)
%attr(0755,root,root)
/var/chef/cookbooks/druid
%defattr(0644,root,root)
/var/chef/cookbooks/druid/README.md


%doc

%changelog
* Thu Oct 10 2024 Miguel Negrón <manegron@redborder.com>
- Add pre and postun

* Thu Jan 18 2024 David Vanhoucke <dvanhoucke@redborder.com>
- Add namespaces to rb_state datasource

* Fri Dec 15 2023 David Vanhoucke <dvanhoucke@redborder.com>
- Add suppport for ip sync

* Tue Apr 18 2023 Luis J. Blanco <ljblanco@redborder.com>
- naming monitor topics

* Fri Jan 07 2022 David Vanhoucke <dvanhoucke@redborder.com>
- change register to consul

* Fri Feb 2 2018 Juan J. Prieto <jjprieto@redborder.com>
- Add realtime support

* Tue Oct 18 2016 Alberto Rodríguez <arodriguez@redborder.com>
- first spec version
