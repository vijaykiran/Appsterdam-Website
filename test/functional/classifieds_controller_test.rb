require File.expand_path('../../test_helper', __FILE__)

describe "On the", ClassifiedsController, "a visitor" do
  should.require_login.get :new
  should.require_login.post :create
end

describe "On the", ClassifiedsController, "a member" do
  before do
    login(members(:developer))
  end

  it "sees a form to create a new ad" do
    get :new
    status.should.be :ok
    template.should.be 'classifieds/new'
  end

  it "can post an ad" do
    lambda {
      post :create, :classified => {
        :offered => true, :category => 'bikes',
        :title => 'A great granny bike!', :description => "It's quite simply the most awesome bike in town."
      }
    }.should.differ('@authenticated.reload.classifieds.count', +1)
    should.redirect_to classifieds_url # TODO will we have a show/edit page?
    ad = members(:developer).classifieds.last
    ad.should.be.offered
    ad.category.should == 'bikes'
    ad.title.should == 'A great granny bike!'
    ad.description.should == "It's quite simply the most awesome bike in town."
  end

  it "can edit a classified ad of herself" do
    get :edit, :id => classifieds(:bike).to_param
    status.should.be :ok
    template.should.be 'classifieds/edit'
    assigns(:classified).should == classifieds(:bike)
  end

  it "can update a classified ad of herself" do
    put :update, :id => classifieds(:bike).to_param, :classified => { :offered => 'false' }
    should.redirect_to classifieds_url
    classifieds(:bike).reload.should.be.wanted
  end

  should.disallow.get :edit, :id => classifieds(:house)
end