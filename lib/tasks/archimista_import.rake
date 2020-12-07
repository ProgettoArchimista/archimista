=begin

Esegue l'importazione batch di file aef o in formato XML secondo i tracciati
EAD3, EAC-CPF, SCONS2, ICAR-IMPORT

Lanciare nella console come segue:

    RAILS_ENV=production rake import[<username>,<import_filename>]

dove:
    <username> 
        è la username dell'utente Archimista con cui eseguire l'import
    
    <import_filename>
        è il nome del file da importare che deve essere preventivamente
        copiato nella cartella: #{Rails.root}/public/imports/batch_import/

Esempio:

    RAILS_ENV=production rake import["admin_archimista","Complesso.xml"]

NB: non inserire spazi prima, dopo e tra i valori dei parametri 
        <username> e <import_filename>
    per evitare l'errore: "Don't know how to build task"

=end
require File.join(File.dirname(__FILE__), "../../app/controllers", "application_controller.rb")
require File.join(File.dirname(__FILE__), "../../app/controllers", "imports_controller.rb")
require File.join(File.dirname(__FILE__), "../../config/initializers", "devise.rb")
require File.join(File.dirname(__FILE__), "../../app/models", "user.rb")
require File.join(File.dirname(__FILE__), "../../app/models", "rel_user_group.rb")
require File.join(File.dirname(__FILE__), "../../app/models", "digital_object.rb")
require File.join(File.dirname(__FILE__), "../../config/initializers", "metadata.rb")
require 'fileutils'
require 'active_record'

task :default => [:import]

DEBUG_MODE = false

USO_DEL_TASK = "\n>>> Il task Esegue l'importazione batch di file aef o in formato XML\n    secondo i tracciati EAD3, EAC-CPF, SCONS2, ICAR-IMPORT\n\n    USO DEL TASK:\n    RAILS_ENV=production rake import[<username>,<import_filename>]\n\n    Esempio:\n    RAILS_ENV=production rake import[\"admin_archimista\",\"Complesso.xml\"]\n\n    NB: il file da importare deve essere preventivamente copiato nella cartella:\n        #{Rails.root}/public/imports/batch_import/"

task :import, [:username, :import_filename] do |task, args|

    puts "\n> Esecuzione task di importazione"
    
    if DEBUG_MODE
        puts "\n"
        puts "+ Rails.root             : #{Rails.root}"
        puts "+ Rails.env              : #{Rails.env}"
        puts "+ Rails.logger.nil?      : #{Rails.logger.nil?}"
        puts "+ Rake file full path    : #{__FILE__}"
        puts "+ args[:username]        : #{args[:username]}"
        puts "+ args[:import_filename] : #{args[:import_filename]}"
    end

    if Rails.logger.nil?
        puts "\n>>> Rails.logger è NIL"
        log_file_name = "#{Rails.env}.log"
        Rails.logger = Logger.new("#{Rails.root}/log/#{log_file_name}")
        puts "\n> Rails.logger sta ora loggando su #{log_file_name}"
        Rails.logger.info "Inizio log del rake task #{__FILE__}"
    end

    I18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]
    I18n.locale = :it
    I18n.default_locale = :it
    puts "\n> I18n.locale    : #{I18n.locale}"
    if DEBUG_MODE
        puts "+ I18n.load_path : #{I18n.load_path}"
        puts "+ I18n.t 'created_at' : #{I18n.t 'created_at'}"  # test di traduzione
    end

    db_config = Rails.application.config.database_configuration[Rails.env]
    if DEBUG_MODE
        puts "\n+ db_config: #{db_config}"
    end

    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection

    if ActiveRecord::Base.connected?
        puts "\n> Connesso al Database"
    else
        puts "\n>>> NON CONNESSO AL DATABASE"
        puts "\n>>> Task terminato."
        exit
    end

    username = args[:username]
    if !username.nil?
        username.strip!
    else
        username = ""
    end

    if username == ""
        puts USO_DEL_TASK
        puts "\n>>> USERNAME DELL'UTENTE PER L'IMPORT NON SPECIFICATO"
        puts "\n>>> Task terminato."
        exit
    end

    batch_import_user = User.where(username: username).first
    if batch_import_user.present?
        puts "\n> Utente per l'import trovato"
        puts "  Username: #{username}"
        puts "  ID      : #{batch_import_user[:id]}"
        puts "  E-mail  : #{batch_import_user[:email]}"
    else
        puts "\n>>> USERNAME DELL'UTENTE PER L'IMPORT NON TROVATO"
        puts "    Username: #{username}"
        puts "\n>>> Task terminato."
        exit
    end

    batch_import_filename = args[:import_filename]
    if !batch_import_filename.nil?
        batch_import_filename.strip!
    else
        batch_import_filename = ""
    end

    if batch_import_filename == ""
        puts USO_DEL_TASK
        puts "\n>>> NOME DEL FILE DA IMPORTARE NON SPECIFICATO"
        puts "\n>>> Task terminato."
        exit
    end

    src_file = File.join(Rails.root, "public", "imports", "batch_import", batch_import_filename)
    if !File.file?(src_file)
        puts USO_DEL_TASK
        puts "\n>>> FILE DA IMPORTARE NON TROVATO"
        puts "    Filename: #{batch_import_filename}"
        puts "\n>>> Task terminato."
        exit
    end

    @imports_controller = ImportsController.new
    @imports_controller.is_batch_import = true
    @imports_controller.batch_import_user = batch_import_user
    @imports_controller.batch_import_filename = batch_import_filename

    require File.join(File.dirname(__FILE__), "../../app/models", "import.rb")

    @imports_controller.new
    @imports_controller.create

end
