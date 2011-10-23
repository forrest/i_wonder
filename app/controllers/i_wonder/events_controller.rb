module IWonder
  class EventsController < ApplicationController
    layout "i_wonder"
    
    def index
      @groups = Event.groups
    end
  
    def show
      @event_details = Event.get_details_for_event_type(params[:id])
    end
  
  end
end
