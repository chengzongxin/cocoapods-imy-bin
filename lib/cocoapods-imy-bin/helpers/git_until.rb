module CBin
    class Git
        class Until
            # 推送文件
            def self.push(path,commit)
                Dir.chdir(path.to_s)
                `git add . && git commit -m "#{commit}" && git pull && git push`
            end

            # 获取最后一次提交commit id
            def self.last_commit_id(path)
                Dir.chdir(path)
                `git rev-parse --short HEAD`.chomp
            end
        end
    end
end
