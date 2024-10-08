package com.example.demo;

import com.example.helloworld.DemoApplication;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ContextConfiguration;

@SpringBootTest
@ContextConfiguration(classes = DemoApplication.class)
class DemoApplicationTests {

	@Test
	void contextLoads() {
	}

}
