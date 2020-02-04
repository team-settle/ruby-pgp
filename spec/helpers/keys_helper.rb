module KeysHelper
  def remove_all_keys
    GPG::Engine.new.delete_all_keys
  end
end