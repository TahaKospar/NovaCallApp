// ============================================================
// Android Root Build Configuration
// ============================================================

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ============================================================
// Build Directory Configuration
// ============================================================
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ⚠️ مهم: evaluationDependsOn لازم تكون في آخر subprojects block
// عشان afterEvaluate تشتغل صح
subprojects {
    project.evaluationDependsOn(":app")
}

// ============================================================
// Force compileSdk 37 on all subprojects (works with AGP 8)
// نستخدم plugins.withId بدل afterEvaluate عشان نتجنب المشكلة
// ============================================================
subprojects {
    plugins.withId("com.android.library") {
        extensions.findByName("android")?.let { androidExt ->
            try {
                androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.java)
                    .invoke(androidExt, 37)
            } catch (_: Exception) { }
        }
    }
    plugins.withId("com.android.application") {
        extensions.findByName("android")?.let { androidExt ->
            try {
                androidExt.javaClass.getMethod("setCompileSdkVersion", Int::class.java)
                    .invoke(androidExt, 37)
            } catch (_: Exception) { }
        }
    }
}

// ============================================================
// Clean Task
// ============================================================
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}