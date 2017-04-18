require 'zimbra/common_elements'
module Zimbra
  class P < Zimbra::A
    def inject(xmldoc)
      xmldoc.add 'pref', value do |pref|
        pref.set_attr 'name', name
        extra_attributes.each do |eaname, eavalue|
          pref.set_attr eaname, eavalue
        end
      end
    end
  end

  class HandsoapPrefsService < HandsoapService
    attr_accessor :token

    def initialize(token)
      self.token = token
    end

    def on_create_document(doc)
      request_namespaces(doc)
      header = doc.find("Header")
      header.add "n1:context" do |s|
        s.set_attr "env:mustUnderstand", "0"
        s.add "n1:authToken", self.token
      end
    end
  end

  class Prefs
    class << self
      def modify_by_account_name(account_name, new_prefs)
        user_zimbra = DelegateAuthToken.for_account_name(account_name)
        if user_zimbra
          pref = PrefsService.new(user_zimbra.token)
          pref.modify(new_prefs)
        end
      end
    end
  end

  class PrefsService < HandsoapPrefsService
    def modify(new_prefs)
      xml = invoke("n3:ModifyPrefsRequest") do |message|
        new_prefs.each do |k,v|
          P.inject(message,k ,v)
        end
      end
    end
  end
end
