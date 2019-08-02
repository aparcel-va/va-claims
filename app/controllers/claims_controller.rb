class ClaimsController < ApplicationController
  before_action :setup_from_session
  def index
    if @veteran.present?
      @claims = @user.claims_for(@veteran, @session)
    else
      @claims = TestUser.claims(@session)
    end
  rescue
    redirect_back(fallback_location: root_path, alert: "This user has no claims")
  end

  def show
    if @veteran.present?
      @claim = @user.claim_for(params[:id], @veteran, @session)
    else
      @claim = TestUser.claim(params[:id], @session)
    end
  rescue
    redirect_back(fallback_location: root_path, alert: "You don't have access to this claim")
  end

  def active_itf
    if @veteran.present?
      @itf = @user.active_itf_for(@veteran, @session)
    else
      @itf = @user.active_itf(@session)
    end
  rescue
    redirect_back(fallback_location: root_path, alert: "No Active ITF Exists")
  end

  def submit_itf
    if @veteran.present?
      @itf = @user.submit_itf_for(@veteran, @session)
      flash[:success] = "ITF Submitted for #{@veteran.name}"
    else
      @itf = @user.submit_itf(@session)
      redirect_to active_itf_url
    end
  rescue
    flash[:error] = "Failure to submit ITF"
  end

  def form_526
    @schema = JSON.parse(SchemaService.get_schema('526').body)['data'][0]
  end

  def update_supporting_document
    response = RestClient.post("#{ENV['vets_api_url']}/services/claims/v0/forms/526/#{params[:id]}/attachments", {attachment: params[:attachment]}, TestUser.stub_headers)
    JSON.parse(response&.body)['data']
    redirect_to claim_path(params[:id])
  end

  private

  def setup_from_session
    @session = Session.where(id: session[:id]).first
    @name = @session.id_token_attributes['name']
    name_parts = @name.split(' ')
    @user = TestUser.where('lower(first_name) = ? AND  lower(last_name) = ?', name_parts.first.downcase, name_parts.last.downcase).first
    @user = TestUser.create(first_name: name_parts.first.downcase, last_name: name_parts.last.downcase) unless @user
    @veteran = TestVeteran.find params[:user_id] if params[:user_id].present?
  end
end
