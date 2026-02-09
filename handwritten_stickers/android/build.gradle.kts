allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

gradle.afterProject {
    if (project != rootProject) {
        extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.let { android ->
            if (android.namespace.isNullOrEmpty()) {
                val manifest = file("src/main/AndroidManifest.xml")
                if (manifest.exists()) {
                    val pkg = Regex("""package="([^"]+)"""").find(manifest.readText())?.groupValues?.get(1)
                    if (pkg != null) {
                        android.namespace = pkg
                    }
                }
            }
            android.compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
