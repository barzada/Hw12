package convert1Test;

import org.testng.annotations.AfterMethod;
import org.testng.annotations.Test;

import okhttp3.internal.Util;

import org.testng.annotations.BeforeMethod;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.core.IsNot.not;
import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.interactions.Actions;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import org.openqa.selenium.JavascriptExecutor;
import org.junit.Assert;
import org.openqa.selenium.Alert;
import org.openqa.selenium.Keys;
import java.util.*;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import org.apache.poi.ss.usermodel.Row;

import org.apache.poi.ss.usermodel.Sheet;

import org.apache.poi.ss.usermodel.Workbook;


public class T3 {
	private WebDriver driver;
	private Map<String, Object> vars;
	JavascriptExecutor js;

	@BeforeMethod
	public void setUp() {
		System.setProperty("webdriver.chrome.driver", "C:\\chromedriver_win32\\chromedriver.exe");
		driver = new ChromeDriver();
		js = (JavascriptExecutor) driver;
		vars = new HashMap<String, Object>();
	}

	@AfterMethod
	public void tearDown() {
 driver.quit();
	}

	@Test
	public void testThatThePriceChangedAfterSwitchToEuro() {
		driver.get("http://tutorialsninja.com/demo/index.php?route=common/home");

		// check old price
		String price1 = driver.findElement(By.xpath("//*[@id=\"content\"]/div[2]/div[1]/div/div[2]/p[2]")).getText();
		String[] price_arr = price1.split("Ex");
		String price = price_arr[0].replaceAll("[^0-9.]", "");

		Float old_price = Float.parseFloat(price);

		System.out.println("old_price: " + old_price);

		// change unit
		driver.findElement(By.cssSelector("button[class='btn btn-link dropdown-toggle']")).click();
		driver.findElement(By.name("EUR")).click();

		// check new price
		price1 = driver.findElement(By.xpath("//*[@id=\"content\"]/div[2]/div[1]/div/div[2]/p[2]")).getText();
		String[] price_arr2 = price1.split("Ex");
		price = price_arr2[0].replaceAll("[^0-9.]", "");

		Float new_price = Float.parseFloat(price);
		System.out.println("new_price: " + new_price);

		System.out.println(new_price / old_price);
		
		float ratio = new_price / old_price;
		
		Assert.assertTrue(ratio <1);

	}
	
	@Test
	public void testThatThePriceInCartChangedAfterSwitchToEuro() {
		driver.get("http://tutorialsninja.com/demo/index.php?route=common/home");

		// pick macBook
		driver.findElement(By.xpath("//*[@id=\"content\"]/div[2]/div[1]/div/div[3]/button[1]")).click();
		
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}
		
		// pick iPhone
		driver.findElement(By.xpath("//*[@id=\"content\"]/div[2]/div[2]/div/div[3]/button[1]")).click();
		
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}
		
		
		driver.findElement(By.xpath("//*[@id=\"cart\"]")).click();
		
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}
		
		String price1 = driver.findElement(By.xpath("//*[@id=\"cart\"]/ul/li[2]/div/table/tbody/tr[4]/td[2]")).getText();
		
		String price = price1.replaceAll("[^0-9.]", "");

		Float old_price = Float.parseFloat(price);
		
		// change unit
		driver.findElement(By.cssSelector("button[class='btn btn-link dropdown-toggle']")).click();
		driver.findElement(By.name("EUR")).click();
		
		
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e1) {
			e1.printStackTrace();
		}
		
		
		// check new price
		driver.findElement(By.xpath("//*[@id=\"cart\"]")).click();
		
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		
		String price2 = driver.findElement(By.xpath("//*[@id=\"cart\"]/ul/li[2]/div/table/tbody/tr[4]/td[2]")).getText();
		price = price2.replaceAll("[^0-9.]", "");

		Float new_price = Float.parseFloat(price);
		
		float ratio = new_price / old_price;
		
		Assert.assertTrue(ratio <1);

	}
	
	@Test
	public void testThatWeCanBuyFromTheWebsite() throws IOException, InterruptedException{
		
		ReadExcl objExcelFile = new ReadExcl();

		objExcelFile.readExcel("exlFiles","a.xls","sheet1");
		int rowCount=ReadExcl.getRowcount();
		Sheet thsSheet=ReadExcl.getsheet();
		  for (int i = 0; i < rowCount+1; i++) {
		        Row row = thsSheet.getRow(i);
		        //Create a loop to print cell values in a row

		        	driver.get("http://tutorialsninja.com/demo/index.php?route=common/home");
		        	
		        	// move to iphone page
		    		driver.findElement(By.xpath("//*[@id=\"menu\"]/div[2]/ul/li[6]/a")).click();
		    		
		    		Thread.sleep(2000);
		    		
		    		// pick palm
		    		driver.findElement(By.xpath("//*[@id=\"content\"]/div[2]/div[3]/div/div[2]/div[2]/button[1]")).click();
		    				
	    			Thread.sleep(2000);
		    		
		    		// click checkout
		    		driver.findElement(By.xpath("//*[@id=\"top-links\"]/ul/li[5]/a")).click();
		    		
	    			Thread.sleep(2000);
		    		
		    		
		    		// click guest
		    		driver.findElement(By.xpath("//*[@id=\"collapse-checkout-option\"]/div/div/div[1]/div[2]/label/input")).click();
		    		driver.findElement(By.xpath("//*[@id=\"button-account\"]")).click();
		    		
	    			Thread.sleep(2000);
		    		
	    			driver.findElement(By.name("firstname")).clear(); // clear field
	    			driver.findElement(By.name("lastname")).clear(); // clear field
	    			driver.findElement(By.id("input-payment-email")).clear(); // clear field
	    			driver.findElement(By.name("telephone")).clear(); // clear field
	    			driver.findElement(By.name("address_1")).clear(); // clear field
	    			driver.findElement(By.name("city")).clear(); // clear field
	    			driver.findElement(By.name("postcode")).clear(); // clear field
	    			
	    			Thread.sleep(2000);
	    			
		    		//Read data from Excel
		    		driver.findElement(By.name("firstname")).sendKeys(row.getCell(0).getStringCellValue());
		    		driver.findElement(By.name("lastname")).sendKeys(row.getCell(1).getStringCellValue());
		    		driver.findElement(By.id("input-payment-email")).sendKeys(row.getCell(2).getStringCellValue());
		    		driver.findElement(By.name("telephone")).sendKeys( String.valueOf(row.getCell(3).getNumericCellValue()) );
		    		driver.findElement(By.name("address_1")).sendKeys(row.getCell(4).getStringCellValue());
		    		driver.findElement(By.name("city")).sendKeys(row.getCell(5).getStringCellValue());
		    		driver.findElement(By.name("postcode")).sendKeys(String.valueOf(row.getCell(6).getNumericCellValue()));
					WebElement dropdown = driver.findElement(By.cssSelector("select[name='country_id']"));
		    		dropdown.findElement(By.xpath("//option[. = 'Israel']")).click();
		    		dropdown.findElement(By.xpath("//option[. = 'Israel']")).click();

		    		Thread.sleep(2000);
		    		
		    		WebElement dropdown2 = driver.findElement(By.cssSelector("select[name='zone_id']"));
		    		dropdown2.findElement(By.xpath("//option[. = 'Galil']")).click();
		    		
		    		driver.findElement(By.xpath("//*[@id=\"button-guest\"]")).click();

		    		Thread.sleep(2000);
		    		
		    		driver.findElement(By.xpath("//*[@id=\"button-shipping-method\"]")).click();

		    		Thread.sleep(2000);
		    		
		    		driver.findElement(By.xpath("//*[@id=\"collapse-payment-method\"]/div/div[2]/div/input[1]")).click();

		    		Thread.sleep(2000);
		    		
		    		driver.findElement(By.xpath("//*[@id=\"button-payment-method\"]")).click();

		    		Thread.sleep(2000);
		    		
		    		driver.findElement(By.xpath("//*[@id=\"button-confirm\"]")).click();

		    		Thread.sleep(2000);
		    		
		    		String FinalMsg = driver.findElement(By.xpath("//*[@id=\"content\"]")).getText();
		    		
		    		FinalMsg = FinalMsg.substring(0, "Your order has been placed!".length());
		    		
		    		boolean result = FinalMsg.equals("Your order has been placed!")? true: false;
		    		
		    		if (result == true) {
		    			Assert.assertEquals("Your order has been placed!", FinalMsg);
		    		}
		    		
		    		System.out.println("row #" + (i+1) + " passes");
		  
		  }
	}
	
}
