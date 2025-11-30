import com.android.build.gradle.LibraryExtension

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

// Ensure older third-party Android library modules (for example in pub cache)
// that don't declare an explicit `namespace` still build. This sets a
// safe default namespace for any module that applies the Android library
// plugin but hasn't set `namespace` in its own build file.
subprojects {
    plugins.withId("com.android.library") {
        extensions.findByName("android")?.let { ext ->
            val libExt = ext as? LibraryExtension
            libExt?.let {
                if (it.namespace.isNullOrBlank()) {
                    it.namespace = "com.modalaideas.unbound"
                }
            }
        }
    }
}

// For older plugins that incorrectly set `package="..."` in their
// source AndroidManifest.xml (not allowed with modern AGP), strip that
// attribute at configuration time for the `device_apps` module so the
// manifest processor doesn't fail. This edits the source manifest file
// in-place during the Gradle build run.
subprojects {
    if (project.name == "device_apps" || project.path.contains("device_apps")) {
        val manifestFile = project.file("src/main/AndroidManifest.xml")
        if (manifestFile.exists()) {
            val original = manifestFile.readText()
            val cleaned = original.replace(Regex("\\s*package\\s*=\\s*\"(.*?)\"", RegexOption.IGNORE_CASE), "")
            if (original != cleaned) {
                manifestFile.writeText(cleaned)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
