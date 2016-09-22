require 'rails_helper'

describe SubPostsController do
  
  it "is a subclass of Blogit::PostsController" do
    expect(SubPostsController.superclass).to eq(Blogit::PostsController)
  end
  
  before do
    reset_configuration
  end

  let(:blog_post) { build :post }

  describe "GET 'index'" do
    
    before do
      expect(Post).to receive(:for_index).with(nil).and_return(posts)
    end
    
    let(:posts) { Blogit::Post }

    def do_get(page=nil)
      get :index, page: page 
    end
    
    context "when super is called with a block" do
  
      it 'yields the block with posts' do
        Timecop.freeze do
          expect(posts).to receive(:update_all).with(updated_at: Time.now).and_return([])
          do_get
        end
      end
      
    end  
  
  end
  
  describe "GET 'tagged'" do
    
    before do
      expect(Post).to receive(:for_index).with(nil).and_return(posts)
      expect(posts).to receive(:tagged_with).and_return(posts)
    end
    
    let(:posts) { Blogit::Post }

    def do_get(page=nil)
      get :tagged, page: page, tag: "one"
    end
    
    context "when super is called with a block" do
  
      it 'yields the block with posts' do
        Timecop.freeze do
          expect(posts).to receive(:update_all).with(updated_at: Time.now).and_return([])
          do_get
        end
      end
      
    end  
  
  end
  
  describe "GET 'show'" do
    
    before do
      expect(Post).to receive(:active_with_id).with("1").and_return(post)
    end
    
    let(:post) { create(:post) }

    def do_get(id="1")
      get :show, id: "1"
    end
    
    context "when super is called with a block" do
  
      it 'yields the block with posts' do
        expect(post).to receive(:touch).with(:updated_at)
        do_get
      end
      
    end  
  
  end
end