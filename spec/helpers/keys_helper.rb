module KeysHelper
  def remove_all_keys
    GPGME::Key.find(:public).each do |k|
      k.delete!(true)
    end
    GPGME::Key.find(:secret).each do |k|
      k.delete!(true)
    end
  end
end