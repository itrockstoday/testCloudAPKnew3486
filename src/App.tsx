function App() {
  return (
    <div style={{ fontFamily: 'system-ui, sans-serif', padding: '2rem', maxWidth: '800px', margin: '0 auto', color: '#333' }}>
      <h1>Linux Wizard Academy - Flutter Project</h1>
      <p>This is a native Flutter project initialized for Google Cloud Shell building.</p>
      
      <div style={{ background: '#f5f5f5', padding: '1.5rem', borderRadius: '8px', border: '1px solid #ddd' }}>
        <h2>🛠 How to build your APK in Google Cloud Shell:</h2>
        <ol style={{ lineHeight: '1.8' }}>
          <li>Open your Google Cloud Shell.</li>
          <li>Ensure you have this project repository cloned and navigate to it in the terminal.</li>
          <li>Run the build script: <code>bash cloud_shell_build.sh</code></li>
          <li>The script will clean the build, repair Gradle files, fetch dependencies, and build the release APK.</li>
          <li>If the build succeeds, download your APK from <code>build/app/outputs/flutter-apk/app-release.apk</code></li>
          <li>If it fails, open <code>build_errors.log</code>, copy the text, and share it with AI Studio for troubleshooting!</li>
        </ol>
      </div>

      <p style={{ marginTop: '2rem', color: '#666', fontSize: '0.9rem' }}>
        <em>Note: This preview screen is a placeholder while you compile the actual Flutter Android app in the shell.</em>
      </p>
    </div>
  );
}

export default App;
