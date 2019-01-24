# Upgrade 2.0.0 inizio
Rails.application.routes.draw do

  devise_for :users, :path_names => { :sign_in => 'login', :sign_out => 'logout' }

  resources :users do
    put 'toggle_active', on: :member
  end

  # Polymorphic resources (must be here, prior to parent resources)
  resources :digital_objects, :only => [:destroy] do
    collection do
      get :all
      get :disabled
      get :sort
      get :bulk_destroy
    end
  end
  resources :group_images, :only => [:destroy] do
    collection do
      get :all
      get :disabled
      get :sort
      get :bulk_destroy
    end
  end

  resources :groups do
    resources :group_carousel_images, :except => [:show, :destroy], :controller => "group_images", :type => "carousel"
    resources :group_logo_images, :except => [:show, :destroy], :controller => "group_images", :type => "logo"
  end

  resources :fonds, :except => [:new] do
    member do
      get    :tree
      get    :treeview
      put    :ajax_update
      patch  :ajax_update
      put    :rename
      put    :move
      get    :merge_with
      post   :merge
      get    :split_fond
      post   :split
      get    :trash
      get    :trashed_subtree
      put    :move_to_trash
      put    :restore_subtree
      delete :destroy_subtree
      put    :publish
      put    :unpublish
    end
    collection do
      get  :save_a_tree
      post :saving_the_tree
      get  :list
      post :ajax_create
    end

    resources :units do
      collection do
        get  :gridview
        post :gridview
        get  :grid
        post :add_rows
        put  :remove_rows
        put  :reorder_rows
# Upgrade 2.1.0 inizio
#        get  :new_iccd
# Upgrade 2.1.0 fine
      end
    end
    resources :digital_objects, :except => [:show, :destroy]
  end

  resources :units, :except => [:new] do
    member do
      put   :ajax_update
      patch :ajax_update
      get   :render_full_path
      get   :preferred_event
      get   :textfield_form
      put   :update_event
# Upgrade 2.1.0 inizio
#      get   :edit_iccd
#      get   :show_iccd
# Upgrade 2.1.0 fine
      get   :move
      post  :move_down
      post  :move_up
    end
    collection do
      get :list_oa_mtc
      get :list_oa_ogtd
      get :list_bdm_ogtd
      get :list_bdm_mtcm
      get :list_bdm_mtct
# Upgrade 2.1.0 inizio
      get :sc2_voc_list
# Upgrade 2.1.0 fine
      put :classify
    end

    # OPTIMIZE: rinominare in subunits ?
    resources :children, :controller => 'units', :only => 'new' do
      collection do
# Upgrade 2.1.0 inizio
#        get :new_iccd
# Upgrade 2.1.0 fine
      end
    end
    resources :digital_objects, :except => [:show, :destroy]
  end

  resources :creators do
    collection do 
      get :list
    end
    resources :digital_objects, :except => [:show, :destroy]
  end

  resources :custodians do
    collection do
      get :list
    end
    resources :digital_objects, :except => [:show, :destroy]
  end

  resources :sources do
    collection do
      get :list
    end
    resources :digital_objects, :except => [:show, :destroy]
  end

  resources :institutions do
    collection do
      get :list
    end
  end

  resources :document_forms do
    collection do
      get :list
    end
  end

  resources :projects do
    collection do
      get :list
      put :publish
      put :unpublish
    end
  end

  resources :editors do
    collection do
      get  :list
      get  :modal_new
      post :modal_create
    end
  end

  # Strumenti
  resources :headings do
    collection do
      get  :import_csv
      post :preview_csv
      post :save_csv
      get  :list
      get  :modal_new
      post :modal_create
      get  :modal_link
      get  :ajax_list
      post :ajax_remove
      post :ajax_link
    end
  end

  resources :anagraphics do
    collection do
      get  :import_csv
      post :preview_csv
      post :save_csv
      get  :list
      get  :modal_new
      post :modal_create
      get  :modal_link
      get  :ajax_list
      post :ajax_remove
      post :ajax_link
    end
  end

  resources :reports, :only => [:index] do
    member do
      get  :dashboard
      get  :summary
      get  :inventory
      post :inventory
      get  :creators
      get  :custodians
      get  :labels
      get  :units
      get  :custodian
      post :custodian
      get  :project
      post :project
    end
    collection do
      get :download
    end
  end

  resources :quality_checks, :only => [:index] do
    member do
      get :fond
      get :creator
      get :custodian
    end
  end

# Upgrade 3.0.0 inizio
resources :multiple_occours, :only => [:index] do
    member do
      post :merge
    end
  end
# Upgrade 3.0.0 fine

  resources :imports, :only => [:index, :new, :create, :destroy]
  resources :exports, :only => [:index] do
    collection do
      get :download
      get :xml
# Upgrade 2.2.0 inizio
      post :units
# Upgrade 2.2.0 fine
    end
  end

  # Vocabolari
  resources :vocabularies, :only => [:index]

  resources :creator_corporate_types, :only => [:index]
  resources :custodian_types, :only => [:index]
  resources :source_types, :only => [:index]

  resources :activities, :only => [:index] do
    collection do
      get :list
    end
  end
  resources :places, :only => [:index] do
    collection do
      get :cities
      get :countries
    end
  end
  resources :langs, :only => [:index]

  # Non-Resourceful Routes
  root :to => 'site#dashboard'
  resources :about, :only => [:index], :to => "site#about"
  match :parse_textile, :only => [:index], :to => "site#parse_textile", :via => [:get, :post]

end

# Upgrade 2.0.0 fine
