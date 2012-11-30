class IB::Project
  def write app_path = "app", resources_path = "resources", pods_headers_path = "vendor/Pods/Headers"
    project = Xcodeproj::Project.new
    target = project.new_target(:static_library, 'ui', :ios)

    resources = project.new_group('Resources')
    support   = project.new_group('Supporting Files') 
    pods      = project.new_group('Pods')

    IB::Generator.new.write(app_path, "ib.xcodeproj")

    support.new_file "ib.xcodeproj/Stubs.h"
    file = support.new_file "ib.xcodeproj/Stubs.m"
    target.add_file_references([ file ])

    resource_exts = %W{xcdatamodeld png jpg jpeg storyboard xib lproj}
    Dir.glob("#{resources_path}/**/*.{#{resource_exts.join(",")}}") do |file|
      if file.end_with? ".xcdatamodeld"
        resources.new_xcdatamodel_group(file)
      else
        resources.new_file(file)
      end
    end

    Dir.glob("#{pods_headers_path}/**/*.h") do |file|
      pods.new_file(file)
    end

    # Add Basic System Frameworks
    # frameworks = ["UIKit", "QuartzCore", "CoreGraphics", "CoreData"]
    # doesn't work with UIKit

    frameworks = ["QuartzCore", "CoreGraphics", "CoreData"]
    frameworks.each do |framework|
      file = project.add_system_framework framework
    end

    project.save_as("ib.xcodeproj")
  end
end
