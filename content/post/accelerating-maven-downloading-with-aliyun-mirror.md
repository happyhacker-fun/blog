---
title: "使用阿里云加速依赖管理"
date: 2020-03-29T00:21:43+08:00
description: ""
tags: ["java", "maven", "gradle"]
categories: ["in-action"]
---

开发Java应用的过程中通常需要依赖大量的第三方包，而由于众所周知的原因，我们访问这些资源的速度非常慢，感谢阿里云给我们提供了一个选项可以快速访问这些资源。

<!--more-->

下面分别是使用maven和gradle时的配置。

## maven

将以下内容写入`$HOME/.m2/settings.xml`中。

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
  https://maven.apache.org/xsd/settings-1.0.0.xsd">
	<!-- <localRepository/> -->
	<!-- <interactiveMode/> -->
	<!-- <offline/> -->
	<!-- <pluginGroups/> -->
	<!-- <servers/> -->
	<mirrors>
		<mirror>
			<id>aliyunmaven</id>
			<mirrorOf>*</mirrorOf>
			<name>阿里云公共仓库</name>
			<url>https://maven.aliyun.com/repository/public</url>
		</mirror>
	</mirrors>
	<!-- <proxies/> -->
	<!-- <profiles/> -->
	<profiles>
		<profile>
			<id>jdk-1.8</id>
			<activation>
				<activeByDefault>true</activeByDefault>
				<jdk>1.8</jdk>
			</activation>
			<properties>
				<maven.compiler.source>1.8</maven.compiler.source>
				<maven.compiler.target>1.8</maven.compiler.target>
				<maven.compiler.compilerVersion>1.8</maven.compiler.compilerVersion>
			</properties>
		</profile>
	</profiles>
	<!-- <activeProfiles/> -->
</settings>
```

## gradle

### 单个项目

在`buile.gradle`中添加以下配置

```groovy
buildscript {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google/' }
        maven { url 'https://maven.aliyun.com/repository/jcenter/'}
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:2.2.3'

        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }        
}

allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google/' }
        maven { url 'https://maven.aliyun.com/repository/jcenter/'}
    }
}
```

#### 全局生效

将以下内容写入`$HOME/.gradle/init.gradle`中。

```groovy
allprojects{
    repositories {
        def ALIYUN_REPOSITORY_URL = 'https://maven.aliyun.com/repository/public/'
        def ALIYUN_JCENTER_URL = 'https://maven.aliyun.com/repository/jcenter/'
        def ALIYUN_GOOGLE_URL = 'https://maven.aliyun.com/repository/google/'
        def ALIYUN_GRADLE_PLUGIN_URL = 'https://maven.aliyun.com/repository/gradle-plugin/'
        all { ArtifactRepository repo ->
            if(repo instanceof MavenArtifactRepository){
                def url = repo.url.toString()
                if (url.startsWith('https://repo1.maven.org/maven2/')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $ALIYUN_REPOSITORY_URL."
                    remove repo
                }
                if (url.startsWith('https://jcenter.bintray.com/')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $ALIYUN_JCENTER_URL."
                    remove repo
                }
                if (url.startsWith('https://dl.google.com/dl/android/maven2/')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $ALIYUN_GOOGLE_URL."
                    remove repo
                }
                if (url.startsWith('https://plugins.gradle.org/m2/')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by $ALIYUN_GRADLE_PLUGIN_URL."
                    remove repo
                }
            }
        }
        maven { url ALIYUN_REPOSITORY_URL }
        maven { url ALIYUN_JCENTER_URL }
        maven { url ALIYUN_GOOGLE_URL }
        maven { url ALIYUN_GRADLE_PLUGIN_URL }
    }
}
```


