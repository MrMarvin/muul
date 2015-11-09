require 'htauth'
require 'net/ldap'

module Muul
  class Authenticator

    def initialize
      @htpasswd = nil
    end

    def htpasswd
      return @htpasswd if @htpasswd
      begin
        @htpasswd = HTAuth::PasswdFile.open(ENV['MUUL_BASIC_AUTH_FILE'])
      rescue => e
        puts "something was wrong with the htpasswd file: #{e}"
      end
    end

    def try_htpasswd(credentials)
      htpasswd && htpasswd.fetch(credentials[0]) && htpasswd.fetch(credentials[0]).authenticated?(credentials[1])
    end

    def try_ldap(credentials)
      parsed_ldap_url = URI.parse(ENV['MUUL_LDAP_URL'])
      ldap_dn_username = parsed_ldap_url.path.gsub('/','')+'='+credentials[0]+','+parsed_ldap_url.query
      ldap = Net::LDAP.new :host => parsed_ldap_url.host,
        :port => parsed_ldap_url.port || parsed_ldap_url.scheme == 'ldaps' ? 636 : 389,
        :base => parsed_ldap_url.query,
        :auth => {
           :method => :simple,
           :username => ldap_dn_username,
           :password => credentials[1]
        }
        ldap.encryption(:simple_tls) if parsed_ldap_url.scheme == 'ldaps'
        puts "trying #{ldap_dn_username} against #{parsed_ldap_url} ..."
      return ldap.bind
    rescue => e
      puts "somethings wrong with your ldap: #{e}"
      return false
    end

    def valid?(credentials)
      try_htpasswd(credentials) || try_ldap(credentials)
    end

  end
end