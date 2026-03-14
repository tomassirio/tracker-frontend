allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Keep kotlin-stdlib aligned with the Kotlin plugin version declared in
    // settings.gradle.kts so that pre-compiled library metadata is readable.
    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "org.jetbrains.kotlin" && requested.name.startsWith("kotlin-stdlib")) {
                useVersion("2.3.0")
            }
        }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
