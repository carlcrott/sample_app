# == Schema Information
# Schema version: 20100704152823
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation, :photo
  
  # Photo validations.
  has_attached_file :photo, :styles => { :small => "150x150>" },
                    :url  => "/assets/products/:id/:style/:basename.:extension",
                    :path => ":rails_root/public/assets/products/:id/:style/:basename.:extension"

  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 5.megabytes
  validates_attachment_content_type :photo, :content_type => ['image/jpeg', 'image/png'] 

  EmailRegex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  validates_presence_of		 :name, :email
  validates_length_of 		 :name, :maximum => 50
  validates_format_of			 :email, :with => EmailRegex
  validates_uniqueness_of  :email, :case_sensitive => false

	# Automatically create the virtual attribute 'password_confirmation'.
  validates_confirmation_of :password

  # Password validations.
  validates_presence_of :password
  validates_length_of   :password, :within => 6..40

  # Password encryption
	before_save :encrypt_password

	def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

	def remember_me!
    self.remember_token = encrypt("#{salt}--#{id}--#{Time.now.utc}")
    save_without_validation
  end

	def self.authenticate(email, submitted_password)
	  user = find_by_email(email)
	  user && user.has_password?(submitted_password) ? user : nil
	end

	private

	  def encrypt_password
			unless password.nil?
        self.salt = make_salt
        self.encrypted_password = encrypt(password)
      end
	  end

	  def encrypt(string)
	    secure_hash("#{salt}#{string}")
	  end

		def make_salt
      secure_hash("#{Time.now.utc}#{password}")
    end

    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
	
end


