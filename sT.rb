require 'rubygems'
require 'selenium-webdriver'
require 'test/unit'

def rap(var)
begin
  t = Time.now.to_i
  file = File.open("test_set_#{t}.txt", "w")
  file.write(var) 
  rescue IOError => e
    #some error occur, dir not writable etc.
  ensure
    file.close unless file == nil
  end
end 
 

def fail(rapo,screen)
     faill = String.new(rapo)
     rap(fail)
     puts fail
     driver.save_screenshot(screen)
end 
 
driver = Selenium::WebDriver.for :firefox
driver.get "http://cat2-qa.cloudapp.net/"
driver.manage.timeouts.implicit_wait = 30
wait = Selenium::WebDriver::Wait.new(:timeout => 15)

#Logging in
LoginButton = driver.find_element(:id, "UserName")
LoginButton.send_keys "test_o"

pass = driver.find_element(:id, "Password")
pass.send_keys "test_o"
pass.submit




#Navigate to Unit
driver.find_element(:xpath, "//*[@id='tree-pane']/ul/li[11]/span/a").click
driver.find_element(:xpath, "//*[@id='tree-pane']/ul/li[11]/ul/li[1]/span/a").click
raport = String.new("Raport:\n")


#Checkbox, checking if element is displayed
checkbox = driver.find_element(:id, "IsBlocked")
#checkbox = wait.until{
#    element = driver.find_element(:id, "IsBlocked")
#    element if element.displayed?
#}
if !checkbox
     fail("Step 4 failure: blocked does not exist",'blockedExistFailure.png') 
else 
  puts "4.Test Passed: The element Blocked exists"
  raport  = raport + "4.Test Passed: The Blocked exists\n" 
   element_class_attribute = checkbox.attribute("type")
  if checkbox.attribute("type")=="checkbox"
    puts "Element Blocked is checkbox"
    #STEP 5  change state of checkbox
      if !checkbox.selected?
        puts "5.checkbox is not selected"
        raport  = raport + "5.Blocked is not selected.\n"
        checkbox.click
       else if checkbox.selected?
          puts "5.checkbox is selected"
           raport  = raport + "5.Blocked is selected\n"
           checkbox.click
        else
          fail("Step 5 failure","editBlockedFail.png")      
          driver.quit
        end
      end
   else
     fail("Step 4 failure: Blocked is not checkbox","blockedTypeFailure.png")
      
  end
end



#STEP 6
if checkbox.selected?
     reason = driver.find_element(:xpath, ".//*[@id='BlockedReason']")
     reason.clear
     reason.send_keys "test reason true"
     puts '6.true, reason is empty'
     raport = raport + "6.True,reason is empty\n"
     puts reason.text

else if !checkbox.selected?
       puts "Checkbox not selected"
       reason = driver.find_element(:xpath, ".//*[@id='BlockedReason']")
       if reason
         puts "Hidden"
       end
       raport = raport +"6.Checkbox not selected\n"
  else
       fail("Step 6 failure\n","checkboxSelectFailure.png")
       driver.quit
    end
end


#Status menu
option = Selenium::WebDriver::Support::Select.new(driver.find_element(:xpath => "//*[@id='status']"))
opt = driver.find_element(:xpath => "//*[@id='status']")

#opt = wait.until {
#    element = driver.find_element(:xpath,"//*[@id='status']")
#    element if element.displayed?
#}
if !opt
  puts "1. Test not passed: The status menu do not exists" 
  fail("1. Test not passed: The status menu do not exists\n","selectExistsFailure.png")
else
  puts "1. Test Passed: The status menu exists" 
  raport += "1. Test Passed: The status menu exists\n" 

  element_class_attribute = opt.attribute("class")
  puts "Atrybut statusu"
  puts element_class_attribute


  #Checking if Status Field is drop down menu by checking if user can select multiply values
  if !(option.multiple?)
  puts "2.Status field exists and it is type of drop down"
  raport +="2.Status field exists and it is type of drop down\n"
    else
      fail("Failure: Step 2 failed","statusFieldTypeFailure.png\n")
      driver.quit
  end

  #Checking
    first = option.first_selected_option()
    $i=0
    $num =8
    tmp = Array.new
    opcje = Array.new
    
    while $i < $num do
      tmp << option.select_by(:index, $i) #Selecting each value in Status field 
      opcje << option.first_selected_option()#Saving each value from Status field in array
      $i +=1 
    end
    f1 = option.select_by(:index, 0)
    
    puts "Default value"
    puts first
    if first!=opcje[1] #If default value do not equals first value in drop down menu, select first value from menu
      option.select_by(:index, 1)
      puts "3.Selected value:"
      raport = raport + "3.Default value does not equals 'Not Started'\n"
      puts opcje[1]
    else if first=opcje[1]#If default value equals first value in menu, select 4th value from menu
      puts "3.Default value equals Not started"
      raport = raport + "3.Default value equals 'Not Started' \n"
      option.select_by(:index, 3)
     else
        fail("Failure: Step 3 failed\n","statusFieldEditFailure.png")
        driver.quit
      end
    end
end

#STEP 7
name = driver.find_element(:xpath, ".//*[@id='UnitName']")
if !name
    fail("Failure: 7.Test Failed: Textfield Name does not exist\n","nameFieldFailure.png")
    rap(fail)
else
    puts "7.Test Passed: Textfield Name exists"
    raport = raport + "7.Test Passed: Textfield Name exists\n"
    ecl = name.attribute("value")
    if ecl.length>45
      ecl = ecl[0,45]
    end
    puts "Value:"
    puts ecl
  
    r =  1 + Random.rand(9)  
    if ecl
      puts name.text
    else if !name.text
          puts "Where is value?"
        else
            fail("Failure: 8.\n","nameFieldFailure.png")
            rap(fail)
         end
      end
#STEP 8
    puts "8. Editing name field"
    newName = String.new("Auto")
    newName = newName + r.to_s
    newName += " s"
    newName += ecl.to_s
    name.clear()
    name.send_keys newName
end

#STEP 9
driver.find_element(:xpath,".//*[@id='button-save-unit']").click

save_raport = driver.find_element(:xpath,".//*[@id='detail-pane']/header/div[2]/span")
save_raport = wait.until{
    element = driver.find_element(:xpath,".//*[@id='detail-pane']/header/div[2]/span")
    element if element.displayed?
}

if save_raport 
    puts "9.Test Passed: Save confirmation appears" 
    raport += "9.Test Passed: Save confirmation appears\n" 
 else
    fail("Failure: 9.Test Passed: Save confirmation does not appear\n","savefailure.png")
    driver.quit
end
driver.save_screenshot("check_0.png")
rap(raport)
ecl = name.attribute("value")
puts ecl.length



checkbox = driver.find_element(:id, "IsBlocked")

chck = checkbox.attribute("value")
reason = driver.find_element(:xpath, ".//*[@id='BlockedReason']")
r0 = reason.attribute("value")


driver.navigate.refresh
driver.find_element(:partial_link_text, "ELA - Grade 5").click
driver.find_element(:partial_link_text, ecl).click


driver.find_element(:xpath, "//*[@id='tree-pane']/ul/li[11]/ul/li[1]/span/a").click


name = driver.find_element(:xpath, ".//*[@id='UnitName']")
checkbox = driver.find_element(:id, "IsBlocked")
reason = driver.find_element(:xpath, ".//*[@id='BlockedReason']")
opt2 = driver.find_element(:xpath,".//*[@id='status']")
  

r1 = reason.attribute("value")
ecl2 = name.attribute("value")
chck2 = checkbox.attribute("value")

  def test_simple
    assert(r1)
  end

if ecl == ecl2 && chck==chck2 && r0==r1 
  puts "OK"
  driver.save_screenshot("check_1.png")
end


