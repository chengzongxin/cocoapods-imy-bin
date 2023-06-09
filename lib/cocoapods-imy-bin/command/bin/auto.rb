
require 'cocoapods-imy-bin/command/bin/auto'
require 'cocoapods-imy-bin/helpers/upload_helper'

module Pod
  class Command
    class Bin < Command
      class Auto < Bin
        self.summary = '打开 workspace 工程.'

        self.arguments = [
            CLAide::Argument.new('NAME.podspec', false)
        ]
        def self.options
          [
              ['--code-dependencies', '使用源码依赖'],
              ['--allow-prerelease', '允许使用 prerelease 的版本'],
              ['--no-clean', '保留构建中间产物'],
              ['--framework-output', '输出framework文件'],
              ['--no-zip', '不压缩静态 framework 为 zip'],
              ['--all-make', '对该组件的依赖库，全部制作为二进制组件'],
              ['--configuration', 'Build the specified configuration (e.g. Release ). Defaults to Debug'],
              ['--env', "该组件上传的环境 %w[dev debug_iphoneos release_iphoneos]"]
          ].concat(Pod::Command::Gen.options).concat(super).uniq
        end

        def initialize(argv)

          @env = argv.option('env') || 'dev'
          CBin.config.set_configuration_env(@env)
          @demo_podspec = Pathname(Dir.pwd) + 'Demo.podspec'
          # 如果目录下没有podspec文件，则会按照podfile文件生成一份
          gen_spec_file_if_need
          @podspec = argv.shift_argument || find_podspec
          @specification = Specification.from_file(@podspec)

          @code_dependencies = argv.flag?('code-dependencies')
          @allow_prerelease = argv.flag?('allow-prerelease')
          @framework_output = argv.flag?('framework-output', false )
          @clean = argv.flag?('clean', true)
          @zip = argv.flag?('zip', true)
          @all_make = argv.flag?('all-make', false )
          @verbose = argv.flag?('verbose',true)

          @config = argv.option('configuration', 'Debug')
          @additional_args = argv.remainder!

          super
        end

        def validate!
          help! "未找到 podspec文件" unless @podspec
          super
        end

        def run
          @specification = Specification.from_file(@podspec)

          source_specs = run_archive

          fail_push_specs = []
          source_specs.uniq.each do |spec|
            begin
              fail_push_specs << spec unless CBin::Upload::Helper.new(spec,@code_dependencies,@sources).upload
            rescue  Object => exception
              UI.puts exception
              fail_push_specs << spec
            end
          end

          if fail_push_specs.any?
            fail_push_specs.uniq.each do |spec|
              UI.warn "【#{spec.name} | #{spec.version}】组件spec push失败 ."
            end
          end

          success_specs = source_specs - fail_push_specs
          if success_specs.any?
            auto_success = ""
            success_specs.uniq.each do |spec|
              auto_success += "#{spec.name} | #{spec.version}\n"
              UI.warn "===【 #{spec.name} | #{spec.version} 】二进制组件制作完成 ！！！ "
            end
            puts "==============  auto_success"
            puts auto_success
            ENV['auto_success'] = auto_success
          end

          clear_demo_podspec

          #pod repo update
          UI.section("\nUpdating Spec Repositories\n".yellow) do
            Pod::Command::Bin::Repo::Update.new(CLAide::ARGV.new([])).run
          end

        end

        def clear_demo_podspec
          FileUtils.rm_rf(@demo_podspec) if @demo_podspec.exist?
        end

        def gen_spec_file_if_need
          if code_spec_files.empty?
            UI.warn "当前目录下没有找到可用源码 podspec. \n "
            # 同步podspec文件与podfile的依赖一致
            gen_local_spec_file
          end
        end

        def gen_local_spec_file
          podfile_name = Pathname.glob('Podfile').first
          local_podfile = Podfile.from_file(podfile_name)

          spec = <<RB
Pod::Spec.new do |s|
  s.name = 'Demo'
  s.version = '1'
  s.description = '我只是一个测试的，主要是想要 s.dependency'
  s.license = 'MIT'
  s.summary = 'Seeyou'
  s.homepage = 'https://github.com/meiyoudev/IMYPublic'
  s.authors = { 'suliangjin' => 'suliangjin@xiaoyouzi.com' }
  s.source = { :git => 'git@github.com:su350380433/cocaos.dependencys-imy-bin.git', :branch => 'dev' }
  s.ios.deployment_target = '9.0'
  # s.source_files = 'Source/**/*.{h,m,c}'
  # s.public_header_files = 'Source/**/*.h'
  #  ========= 三方库 =========
RB

          # s.dependency 'AFNetworking', '4.0.1'
          local_podfile.dependencies.each do | d |
            version = d.requirement.to_s.delete('=').strip!
            spec += "  s.dependency '#{d.name}'"
            spec += ", '#{d.requirement.to_s.delete('=').strip!}'" if !version.nil? && !version.empty?
            spec += "\n"
          end

          spec += 'end'

          File.open(@demo_podspec, 'w') { |file| file.write(spec) }
          # lines.insert(lines.count - 1, dependencies.join("\n"))

          # fw = File.open(file,'w+') # 这里提前打开文件会导致IO文件为空白
          # fw.puts lines
          # fw.close
        end

        #制作二进制包

        def run_archive
          argvs = [
              "--sources=#{sources_option(@code_dependencies, @sources)},https:\/\/cdn.cocoapods.org",
              @additional_args
          ]

          argvs << spec_file if spec_file
          argvs.delete(Array.new)

          unless @clean
            argvs += ['--no-clean']
          end
          if @code_dependencies
            argvs += ['--code-dependencies']
          end
          if @verbose
            argvs += ['--verbose']
          end
          if @allow_prerelease
            argvs += ['--allow-prerelease']
          end
          if @framework_output
            argvs += ['--framework-output']
          end
          if @all_make
            argvs += ['--all-make']
          end
          if @env
            argvs += ["--env=#{@env}"]
          end
          argvs += ["--configuration=#{@config}"]

          archive = Pod::Command::Bin::Archive.new(CLAide::ARGV.new(argvs))
          archive.validate!
          source_specs = archive.run
          source_specs
        end


        def code_podsepc_extname
          '.podsepc'
        end

        def binary_podsepc_json
          "#{@specification.name}.binary.podspec.json"
        end

        def binary_template_podsepc
          "#{@specification.name}.binary-template.podspec"
        end

        def template_spec_file
          @template_spec_file ||= begin
                                    if @template_podspec
                                      find_spec_file(@template_podspec)
                                    else
                                      binary_template_spec_file
                                    end
                                  end
        end

        def spec_file
          @spec_file ||= begin
                           if @podspec
                             find_spec_file(@podspec) || @podspec
                           else
                             if code_spec_files.empty?
                               raise Informative, '当前目录下没有找到可用源码 podspec.'
                             end

                             spec_file = if @binary
                                           code_spec = Pod::Specification.from_file(code_spec_files.first)
                                           if template_spec_file
                                             template_spec = Pod::Specification.from_file(template_spec_file)
                                           end
                                           create_binary_spec_file(code_spec, template_spec)
                                         else
                                           code_spec_files.first
                                         end
                             spec_file
                           end
                         end
        end

        #Dir.glob 可替代
        def find_podspec
          name = nil
          Pathname.pwd.children.each do |child|
            puts child
            if File.file?(child)
              if child.extname == '.podspec'
                  name = File.basename(child)
                  unless name.include?("binary-template")
                    return name
                  end
              end
            end
          end
          return name
        end

      end
    end
  end
end
