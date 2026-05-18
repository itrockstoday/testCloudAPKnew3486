import { useState, useRef, useEffect } from 'react';
import { BookOpen, CheckCircle, TerminalSquare, PlayCircle, Award, Terminal } from 'lucide-react';
import { appLessons, Lesson } from './lessons';

type TerminalLine = {
  text: string;
  isCommand?: boolean;
};

type ProgressState = Record<string, number>;

type UserProfile = {
  firstName: string;
  lastName: string;
  phone: string;
  email: string;
};

function OnboardingForm({ onComplete }: { onComplete: (profile: UserProfile) => void }) {
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (firstName && lastName && phone && email) {
      onComplete({ firstName, lastName, phone, email });
    }
  };

  return (
    <div className="h-[100dvh] bg-gray-950 text-gray-50 font-sans flex items-center justify-center p-4">
      <div className="bg-gray-900 border border-gray-800 rounded-xl p-8 max-w-md w-full shadow-2xl">
        <div className="text-center mb-8">
          <BookOpen className="mx-auto text-indigo-400 mb-4" size={48} />
          <h1 className="text-2xl font-bold text-white mb-2">Welcome to Linux Wizard Academy</h1>
          <p className="text-gray-400">Please provide your contact information to begin your journey.</p>
        </div>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-1">First Name</label>
            <input 
              type="text" required 
              value={firstName} onChange={e => setFirstName(e.target.value)}
              className="w-full bg-gray-950 border border-gray-800 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500 transition"
              placeholder="Harry"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-1">Last Name</label>
            <input 
              type="text" required 
              value={lastName} onChange={e => setLastName(e.target.value)}
              className="w-full bg-gray-950 border border-gray-800 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500 transition"
              placeholder="Potter"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-1">Email</label>
            <input 
              type="email" required 
              value={email} onChange={e => setEmail(e.target.value)}
              className="w-full bg-gray-950 border border-gray-800 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500 transition"
              placeholder="harry@hogwarts.edu"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-400 mb-1">Phone Number</label>
            <input 
              type="tel" required 
              value={phone} onChange={e => setPhone(e.target.value)}
              className="w-full bg-gray-950 border border-gray-800 rounded-lg px-4 py-2 text-white focus:outline-none focus:border-indigo-500 transition"
              placeholder="555-0100"
            />
          </div>
          <button 
            type="submit" 
            className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-3 rounded-lg transition mt-4"
          >
            Enter Academy
          </button>
        </form>
      </div>
    </div>
  );
}

function LessonCard({ lesson, progress, startLesson }: { lesson: Lesson, progress: ProgressState, startLesson: (lesson: Lesson) => void }) {
  const status = progress[lesson.id] || 0;
  let statusText = 'Not Started';
  let StatusIcon = PlayCircle;
  let statusColor = 'text-gray-500';
  
  if (status === 4) {
    statusText = 'Completed (Replay)';
    StatusIcon = CheckCircle;
    statusColor = 'text-green-400';
  } else if (status > 0) {
    statusText = 'In Progress';
    StatusIcon = PlayCircle;
    statusColor = 'text-amber-400';
  }

  return (
    <div 
      onClick={() => startLesson(lesson)}
      className="bg-gray-900 p-5 rounded-xl border border-gray-800 shadow-sm cursor-pointer hover:border-indigo-500 transition group flex flex-col sm:flex-row justify-between sm:items-center gap-4"
    >
      <div className="flex gap-4 items-center">
        <div className={`p-3 rounded-full bg-gray-950 border border-gray-800 group-hover:border-indigo-500 transition shrink-0`}>
          <TerminalSquare size={28} className="text-indigo-400" />
        </div>
        <div>
          <h3 className="text-lg font-bold text-white group-hover:text-indigo-400 transition">{lesson.title}</h3>
          <p className="text-gray-400 text-sm mt-1">{lesson.explanation}</p>
        </div>
      </div>
      <div className="flex sm:flex-col items-center sm:items-end justify-between sm:justify-center gap-2 sm:gap-1 pl-16 sm:pl-0 shrink-0">
        <span className={`text-sm font-semibold ${statusColor}`}>{statusText}</span>
        <StatusIcon className={statusColor} size={24} />
      </div>
    </div>
  );
}

export default function App() {
  const [userProfile, setUserProfile] = useState<UserProfile | null>(() => {
    const saved = localStorage.getItem('linux_wizard_profile');
    return saved ? JSON.parse(saved) : null;
  });
  const [currentView, setCurrentView] = useState<'dashboard' | 'terminal' | 'resume' | 'modules'>('dashboard');
  const [activeLesson, setActiveLesson] = useState<Lesson | null>(null);
  const [progress, setProgress] = useState<ProgressState>({});
  
  // Terminal state
  const [output, setOutput] = useState<TerminalLine[]>([]);
  const [currentPhase, setCurrentPhase] = useState<'none' | 'demonstrate' | 'imitate' | 'practice'>('none');
  const [currentStageIndex, setCurrentStageIndex] = useState(0);
  
  // Fake File System
  const [fileSystem, setFileSystem] = useState<Set<string>>(new Set([
    'virtual_home', 
    'Coloring_Books', 
    'Puzzles', 
    'Action_Figures',
    'spell_book.txt',
    'magic_wand.sh',
    'potions_recipe.md',
    '.secret_diary',
    '.hidden_orb'
  ]));
  
  useEffect(() => {
    // Load from local storage
    const saved = localStorage.getItem('linux_wizard_progress');
    if (saved) {
      try {
        setProgress(JSON.parse(saved));
      } catch (e) {}
    }
  }, []);

  const saveUserProfile = (profile: UserProfile) => {
    setUserProfile(profile);
    localStorage.setItem('linux_wizard_profile', JSON.stringify(profile));
  };

  const saveProgress = (lessonId: string, state: number) => {
    const next = { ...progress, [lessonId]: state };
    setProgress(next);
    localStorage.setItem('linux_wizard_progress', JSON.stringify(next));
  };

  const printLine = (text: string, isCommand = false) => {
    setOutput((prev) => [...prev, { text, isCommand }]);
  };

  const startLesson = (lesson: Lesson) => {
    setActiveLesson(lesson);
    setCurrentPhase('demonstrate');
    setCurrentStageIndex(0);
    saveProgress(lesson.id, 1);
    setOutput([
      { text: `Starting lesson: ${lesson.title}` },
      { text: lesson.explanation },
      { text: '--- DEMONSTRATION PHASE ---' }
    ]);
    setCurrentView('terminal');
  };

  const processCommand = (command: string, isDemo = false, lesson = activeLesson, phase = currentPhase, stageIndex = currentStageIndex) => {
    if (phase === 'demonstrate') {
      if (lesson && stageIndex < lesson.demonstrations.length) {
        const cmd = lesson.demonstrations[stageIndex];
        printLine(`Watch closely! Magic spell: $ ${cmd}`);
        executeCommand(cmd);

        const nextIndex = stageIndex + 1;
        if (nextIndex < lesson.demonstrations.length) {
          setCurrentStageIndex(nextIndex);
        } else {
          setCurrentPhase('imitate');
          setCurrentStageIndex(0);
          saveProgress(lesson.id, 2);
          printLine('\\n--- IMITATE PHASE ---');
          printLine(`Now it's your turn! Type exactly this: ${lesson.imitations[0]}`);
        }
      }
      return;
    }

    if (!command.trim()) return;

    if (!isDemo) {
      printLine(`$ ${command}`, true);
    }

    if (!isDemo && lesson && phase === 'imitate') {
      const expected = lesson.imitations[stageIndex];
      if (command.trim() === expected) {
        executeCommand(command);
        printLine('Great job!');
        
        const nextIndex = stageIndex + 1;
        if (nextIndex < lesson.imitations.length) {
          setCurrentStageIndex(nextIndex);
          printLine(`Now type exactly this: ${lesson.imitations[nextIndex]}`);
        } else {
          setCurrentPhase('practice');
          setCurrentStageIndex(0);
          saveProgress(lesson.id, 3);
          printLine('--- PRACTICE PHASE ---');
          printLine(`CHALLENGE: ${lesson.practices[0].description}`);
        }
        return;
      } else {
        printLine(`Try again! Type exactly: ${expected}`);
        return;
      }
    }

    if (!isDemo && lesson && phase === 'practice') {
      const practice = lesson.practices[stageIndex];
      const rx = new RegExp(practice.expectedCommandPattern);
      if (rx.test(command.trim())) {
        executeCommand(command);
        printLine('Correct! You did it!');
        
        const nextIndex = stageIndex + 1;
        if (nextIndex < lesson.practices.length) {
          setCurrentStageIndex(nextIndex);
          printLine(`CHALLENGE: ${lesson.practices[nextIndex].description}`);
        } else {
          saveProgress(lesson.id, 4);
          printLine(`🌟 LESSON COMPLETE: ${lesson.title} 🌟`);
          printLine(`Skill Unlocked: ${lesson.skillEarned}`);
          setActiveLesson(null);
          setCurrentPhase('none');
          setCurrentStageIndex(0);
        }
        return;
      }
      
      executeCommand(command);
      printLine("That didn't seem like the right magic spell for the challenge. Try again!");
      printLine(`CHALLENGE: ${practice.description}`);
      return;
    }

    executeCommand(command);
  };

  const executeCommand = (command: string) => {
    const parts = command.trim().split(/\s+/);
    const cmd = parts[0];
    const args = parts.slice(1);

    switch (cmd) {
      case 'ls': {
        const long = args.includes('-l');
        const all = args.includes('-a');
        let txt = '';
        if (all) {
          txt += '.  ..  ';
        }
        // Fake file system items
        const items = Array.from(fileSystem).filter(f => f !== 'virtual_home');
        let fileCount = 0;
        items.forEach(item => {
          if (item.startsWith('.') && !all) return;
          fileCount++;
          if (long) {
            const size = item.includes('.') ? '1024' : '4096';
            const isDir = !item.includes('.');
            const perms = isDir ? 'drwxr-xr-x' : '-rw-r--r--';
            printLine(`${perms} 1 wizard wizard ${size} Jan 1 12:00 ${item}`);
          } else {
            txt += `${item}   `;
          }
        });
        if (!long && txt) {
            printLine(txt);
        } else if (!fileCount && !all) {
            // Nothing to print
        }
        break;
      }
      case 'mkdir': {
        if (args.length === 0) {
          printLine('mkdir: missing operand (Tell me what to name the new box!)');
          return;
        }
        const newDirs = new Set(fileSystem);
        args.forEach(arg => newDirs.add(arg));
        setFileSystem(newDirs);
        break;
      }
      case 'cd': {
        if (args.length === 0 || args[0] === '~') {
          printLine('Returning to home...');
        } else {
          printLine(`Entering ${args[0]}...`);
        }
        break;
      }
      case 'touch': {
        if (args.length === 0) {
          printLine('touch: missing file operand'); return;
        }
        const newFiles = new Set(fileSystem);
        args.forEach(arg => newFiles.add(arg));
        setFileSystem(newFiles);
        break;
      }
      case 'rm': {
        if (args.length === 0) {
          printLine('rm: missing operand'); return;
        }
        const newFiles = new Set(fileSystem);
        args.forEach(arg => newFiles.delete(arg));
        setFileSystem(newFiles);
        break;
      }
      case 'cat': {
         if (args.length === 0) { printLine('cat: missing file operand'); return; }
         if (!fileSystem.has(args[0])) { printLine(`cat: ${args[0]}: No such file or directory`); return; }
         printLine(`(Reading contents of ${args[0]}...)`);
         printLine('Magic words are written here.');
         break;
      }
      case 'vi': {
         if (args.length === 0) { printLine('vi: missing file operand'); return; }
         printLine(`(Opening ${args[0]} in vi...)`);
         printLine(`(Simulated: You use 'i' to insert, write text, and hit ESC, then ':wq' to save)`);
         const newFiles = new Set(fileSystem);
         newFiles.add(args[0]);
         setFileSystem(newFiles);
         break;
      }
      case 'pwd':
        printLine('/home/wizard');
        printLine('(Real Android Path simulated: /data/user/0/com.example/app_flutter/linux_academy_home)');
        break;
      case 'clear':
        setOutput([]);
        break;
      default:
        printLine(`bash: ${cmd}: command not found (Wait, is this a made-up spell?)`);
    }
  };

  if (!userProfile) {
    return <OnboardingForm onComplete={saveUserProfile} />;
  }

  return (
    <div className="h-[100dvh] bg-gray-950 text-gray-50 font-sans flex flex-col overflow-hidden">
      <header className="bg-gray-900 text-indigo-400 p-3 md:p-4 flex items-center justify-between shadow-md border-b border-gray-800 shrink-0">
        <h1 className="text-lg md:text-xl font-bold flex items-center gap-2">
          <BookOpen size={20} /> <span className="hidden sm:inline">Linux Wizard Academy</span><span className="sm:hidden">LWA</span>
        </h1>
        <div className="flex gap-2 md:gap-4 text-sm md:text-base">
          <button 
            onClick={() => setCurrentView('resume')}
            className={`flex items-center gap-1 font-medium transition-colors ${currentView === 'resume' ? 'text-yellow-400' : 'hover:text-indigo-300'}`}
          >
            <Award size={18} /> Resume
          </button>
          <button 
            onClick={() => {
              setCurrentView('dashboard');
              setActiveLesson(null);
            }}
            className="flex items-center gap-1 font-medium hover:text-indigo-300 transition-colors"
          >
            <BookOpen size={18} /> Lessons
          </button>
        </div>
      </header>

      <main className="flex-1 p-2 sm:p-4 md:p-6 max-w-4xl w-full mx-auto flex flex-col min-h-0 overflow-y-auto">
        {currentView === 'dashboard' && (() => {
          const completedCount = appLessons.filter(l => progress[l.id] === 4).length;
          const nextLesson = appLessons.find(l => (progress[l.id] || 0) < 4) || appLessons[appLessons.length - 1];

          return (
            <div className="space-y-6">
              <div className="bg-gray-900 p-6 rounded-xl border border-gray-800 shadow-sm flex flex-col md:flex-row justify-between items-center gap-4">
                <div>
                  <h2 className="text-xl font-semibold mb-2 text-white">Welcome back, {userProfile.firstName}!</h2>
                  <p className="text-gray-400">
                    You have completed <span className="text-yellow-400 font-bold">{completedCount}</span> out of <span className="text-white font-bold">{appLessons.length}</span> modules.
                  </p>
                </div>
                <button 
                  onClick={() => setCurrentView('modules')}
                  className="bg-gray-800 hover:bg-gray-700 text-white px-4 py-2 rounded-lg font-medium transition shadow border border-gray-700 w-full md:w-auto whitespace-nowrap"
                >
                  View All Modules
                </button>
              </div>

              <div className="space-y-4">
                <h3 className="text-lg font-bold text-gray-300 px-1">
                  {completedCount === appLessons.length ? 'You completed everything! Replay a module:' : 'Up Next:'}
                </h3>
                <LessonCard lesson={nextLesson} progress={progress} startLesson={startLesson} />
              </div>
            </div>
          );
        })()}

        {currentView === 'modules' && (
          <div className="space-y-6">
            <div className="flex justify-between items-center px-1">
              <h2 className="text-xl font-bold text-white">All Modules</h2>
              <button 
                onClick={() => setCurrentView('dashboard')}
                className="text-indigo-400 hover:text-indigo-300 text-sm font-medium transition"
              >
                &larr; Back to Dashboard
              </button>
            </div>
            <div className="space-y-4">
              {appLessons.map((lesson) => (
                <LessonCard key={lesson.id} lesson={lesson} progress={progress} startLesson={startLesson} />
              ))}
            </div>
          </div>
        )}

        {currentView === 'terminal' && (
          <TerminalUI 
            output={output} 
            processCommand={(cmd: string) => processCommand(cmd)} 
            phase={currentPhase}
            title={activeLesson ? activeLesson.title : 'Terminal'}
            onExit={() => {
              setCurrentView('dashboard');
              setActiveLesson(null);
            }}
            instruction={
              activeLesson ? 
                (currentPhase === 'demonstrate' ? 'Watch closely! Press ENTER or any key to see the next command.' :
                 currentPhase === 'imitate' ? `Type exactly: ${activeLesson.imitations[currentStageIndex] || ''}` :
                 currentPhase === 'practice' ? `Challenge: ${activeLesson.practices[currentStageIndex]?.description || ''}` : '')
              : ''
            }
          />
        )}

        {currentView === 'resume' && (
          <ResumeView progress={progress} profile={userProfile} />
        )}
      </main>
    </div>
  );
}

function TerminalUI({ output, processCommand, phase, title, instruction, onExit }: any) {
  const [input, setInput] = useState('');
  const scrollRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [output]);

  useEffect(() => {
    if (phase !== 'demonstrate') {
      inputRef.current?.focus();
    }
  }, [phase, output]);

  return (
    <div className="flex flex-col flex-1 min-h-0 w-full h-full">
      {instruction && (
         <div className="bg-gray-900 border border-gray-800 rounded-t-xl p-3 shadow-md text-white border-b-0 space-y-1 shrink-0">
            <div className="text-yellow-400 font-bold uppercase tracking-wider text-xs flex items-center gap-2">
               <span>Phase: {phase}</span>
            </div>
            <div className="text-sm">
               {instruction}
            </div>
         </div>
      )}
      <div className={`bg-gray-950 text-green-400 font-mono ${instruction ? 'rounded-b-xl' : 'rounded-xl'} shadow-xl overflow-hidden flex flex-col flex-1 min-h-0 border border-gray-800`}>
        <div className="bg-gray-900/50 p-2 border-b border-gray-800 flex justify-between items-center px-3 shrink-0">
          <div className="flex gap-2">
            <div className="w-2.5 h-2.5 rounded-full bg-red-500" />
            <div className="w-2.5 h-2.5 rounded-full bg-yellow-500" />
            <div className="w-2.5 h-2.5 rounded-full bg-green-500" />
          </div>
          <span className="text-gray-400 text-xs font-sans font-medium flex-1 text-center px-2 truncate leading-tight">{title}</span>
          <button 
             onClick={onExit}
             className="text-white text-[11px] bg-indigo-600 hover:bg-indigo-500 px-2 py-1 rounded shadow transition whitespace-nowrap"
          >
             Exit & Save
          </button>
        </div>
        
        <div 
          ref={scrollRef}
          className="flex-1 p-3 overflow-y-auto min-h-0 text-xs sm:text-sm"
          onClick={() => inputRef.current?.focus()}
        >
          {output.map((line: any, i: number) => (
            <div key={i} className={`mb-1 ${line.isCommand ? 'text-green-300 font-bold' : 'text-gray-300'} whitespace-pre-wrap break-words leading-tight`}>
              {line.text}
            </div>
          ))}
          <div className="flex mt-2 items-center">
            <span className="text-green-500 mr-2 font-bold">$</span>
            <input
              ref={inputRef}
              type="text"
              value={input}
              placeholder={phase === 'demonstrate' ? 'Press any key...' : ''}
              onChange={(e) => {
                 if (phase === 'demonstrate') {
                     processCommand('');
                     setInput('');
                 } else {
                     setInput(e.target.value);
                 }
              }}
              onKeyDown={(e) => {
                if (phase === 'demonstrate') {
                   e.preventDefault();
                   processCommand('');
                   setInput('');
                   return;
                }
                if (e.key === 'Enter') {
                  processCommand(input);
                  setInput('');
                }
              }}
              autoComplete="off"
              spellCheck="false"
              autoCorrect="off"
              autoCapitalize="none"
              className="flex-1 bg-transparent border-none outline-none text-green-400 focus:ring-0 min-w-0"
            />
          </div>
          {phase === 'demonstrate' && (
             <div className="mt-4">
                <button 
                  onClick={() => {
                     processCommand('');
                     inputRef.current?.focus();
                  }}
                  className="w-full bg-indigo-600/20 hover:bg-indigo-600/40 border border-indigo-500/30 text-indigo-300 py-2 rounded text-xs font-sans transition"
                >
                  Press Here or Enter to Continue
                </button>
             </div>
          )}
        </div>
      </div>
    </div>
  );
}

function ResumeView({ progress, profile }: { progress: ProgressState, profile: UserProfile }) {
  const earnedSkills = appLessons
    .filter(l => progress[l.id] === 4)
    .map(l => l.skillEarned);

  const completedCount = earnedSkills.length;
  let jobTitle = "Linux Support Trainee";
  if (completedCount >= 3) jobTitle = "Helpdesk Technician (Linux)";
  if (completedCount >= 5) jobTitle = "Linux Associate";
  if (completedCount >= 7) jobTitle = "Junior Linux Systems Administrator";

  const handleEmailResume = () => {
    const subject = encodeURIComponent(`${profile.firstName} ${profile.lastName} - Linux Academy Resume`);
    const bodyText = `Hello,

Here is my professional resume generated from the Linux Wizard Academy:

Name: ${profile.firstName} ${profile.lastName}
Email: ${profile.email}
Phone: ${profile.phone}

Professional Summary:
Junior Linux Systems Administrator with practical training in core utilities. Capable of executing shell commands for file management, directory traversal, and rapid text operations. Ready to tackle server maintenance and automation scripting.

Technical Competencies:
${earnedSkills.map(s => `- ${s}`).join('\n')}

Thank you!`;
    const body = encodeURIComponent(bodyText);
    window.location.href = `mailto:${profile.email}?subject=${subject}&body=${body}`;
  };

  return (
    <div className="bg-gray-900 border border-gray-800 rounded-xl overflow-hidden shadow-xl flex flex-col">
      <div className="bg-gray-950 p-8 border-b border-gray-800 text-center relative overflow-hidden">
        <div className="absolute top-0 right-0 p-4 opacity-5 pointer-events-none">
           <Terminal size={120} />
        </div>
        <h2 className="text-2xl sm:text-3xl font-extrabold text-white tracking-tight relative z-10">{profile.firstName} {profile.lastName}</h2>
        <p className="text-indigo-400 mt-2 font-medium relative z-10">{jobTitle}</p>
        <p className="text-gray-400 mt-4 max-w-xl mx-auto text-sm sm:text-base relative z-10">
          Proven ability to navigate, manage, and manipulate Unix-like operating systems via the command-line interface. Highly motivated IT professional with hands-on console experience.
        </p>
        <div className="flex flex-wrap justify-center gap-4 mt-6 relative z-10 text-gray-300 text-sm">
          <span>{profile.email}</span>
          <span>&bull;</span>
          <span>{profile.phone}</span>
        </div>
        <div className="mt-6 relative z-10">
          <button 
            onClick={handleEmailResume}
            className="bg-indigo-600 hover:bg-indigo-700 text-white px-6 py-2 rounded-lg font-medium transition shadow"
          >
            Send to Email
          </button>
        </div>
      </div>

      <div className="p-8">
        <h3 className="text-lg uppercase tracking-wider font-bold mb-4 border-b border-gray-800 pb-2 text-gray-500">Professional Summary</h3>
        <p className="text-gray-300 text-sm mb-8 leading-relaxed">
           Junior Linux Systems Administrator with practical training in core utilities. Capable of executing shell commands for file management, directory traversal, and rapid text operations. Ready to tackle server maintenance and automation scripting.
        </p>

        <h3 className="text-lg uppercase tracking-wider font-bold mb-4 border-b border-gray-800 pb-2 text-gray-500">Technical Competencies</h3>
        {earnedSkills.length === 0 ? (
          <p className="text-gray-600 italic">Complete academy modules to populate your professional competencies.</p>
        ) : (
          <ul className="space-y-4">
            {earnedSkills.map((skill, i) => (
              <li key={i} className="flex gap-4 items-start bg-gray-950 p-4 rounded-lg border border-gray-800/60 shadow-inner">
                <CheckCircle className="text-green-500 shrink-0 mt-0.5" size={20} />
                <span className="text-gray-300 text-sm sm:text-base">{skill}</span>
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
