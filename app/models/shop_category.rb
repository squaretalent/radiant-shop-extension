class ShopCategory < ActiveRecord::Base
  default_scope :order => 'position ASC'
  
  belongs_to :parent, :class_name => 'ShopCategory'
  acts_as_list  :scope => :parent
    
  has_many :products, :class_name => 'ShopProduct', :foreign_key => :category_id, :dependent => :destroy
  has_many :children, :class_name => 'ShopCategory', :foreign_key => :parent_id, :order => 'position', :dependent => :destroy
    
  before_validation :set_handle
  before_validation :filter_handle
    
  validates_presence_of :title
  validates_presence_of :handle
  
  validates_uniqueness_of :title
  validates_uniqueness_of :handle
  
  def custom=(values)
    values.each do |key, value|
      self.json_field_set(key, value)
    end
  end
  
  def self.search(search)
    unless search.blank?
      queries = []
      queries << 'LOWER(title) LIKE (:term)'
      queries << 'LOWER(handle) LIKE (:term)'
      queries << 'LOWER(description) LIKE (:term)'
      
      sql = queries.join(" OR ")
      @conditions = [sql, {:term => "%#{search.downcase}%" }]
    else
      @conditions = []
    end
    options = { :conditions => @conditions }
    self.all(options)
  end
  
private
  
  def filter_handle
    unless self.title.nil?
      self.handle = self.handle.downcase.gsub(/[^-a-z0-9~\s\.:;+=_]/, '').strip.gsub(/[\s\.:;=+]+/, '-')
    end
  end
  
  def set_handle
    unless self.title.nil?
      self.handle = self.title if self.handle.nil? or self.handle.empty?
    end
  end
  
end