class FormLineItem
  include Forms::Models::Extension
  
  # line_item:
  #   process: add|update|remove
  
  def create
    @result ||= {}
    find_or_create_current_order
    
    case process
    when 'add'
      @result[:add]    = @order.add(line_item_item_id,line_item_quantity,line_item_item_type)
    when 'modify'
      @result[:modify] = @order.modify(line_item_id,line_item_quantity)
    when 'remove'
      @result[:remove] = @order.remove(line_item_id,line_item_quantity)
    end
    
    @result
  end
  
  protected
    
  # Uses the page session data to find the current order
  def find_or_create_current_order
    begin
      @order = ShopOrder.find(@page.request.session[:shop_order])
    rescue
      @order = ShopOrder.create
      @result[:session] = { :shop_order => @order.id }
    end
    @order.update_attribute(:customer_id, (current_customer.id rescue nil)) # either assign it to a user, or don't
  end
  
  def process
    @config[:process]
  end
  
  def line_item
    @data[:line_item]
  end
  
  def line_item_id
    line_item[:id]
  end
  
  def line_item_item_id
    line_item[:item_id]
  end
  
  def line_item_item_type
    line_item[:item_type]
  end
  
  def line_item_quantity
    line_item[:quantity]
  end
  
end