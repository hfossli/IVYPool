Pod::Spec.new do |s|

    s.name          = "IVYPool"
    s.version       = "0.1"
    s.summary       = "A thread safe pool factory for iOS. Store, get and create objects on demand."
    s.homepage      = "https://bitbucket.org/agens/ivypool"
    s.license       = {
    	:type => 'MIT',
    	:file => 'LICENSE'
    	}
    s.platform      = :ios, '7.0'
    s.requires_arc  = true
    s.authors       = {
    	"Håvard Fossli" => "hfossli@agens.no"
    	}
    s.source        = {
        :git => "git@bitbucket.org:agens/ivypool.git",
        :tag => s.version.to_s
        }
    s.frameworks    = 'Foundation'
    s.source_files  = 'Source/**/*.{h,m,mm,hpp,cpp,c}'
    s.exclude_files  = 'Source/**/*Test.{h,m,mm,hpp,cpp,c}'
end
