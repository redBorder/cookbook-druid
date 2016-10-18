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

%pre

%post

%files
%defattr(0755,root,root)
/var/chef/cookbooks/druid

%doc

%changelog
* Tue Oct 18 2016 Alberto Rodríguez <arodriguez@redborder.com> - 1.0.0-1
- first spec version
