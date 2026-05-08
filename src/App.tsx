import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { 
  Terminal, 
  BookOpen, 
  Trophy, 
  FileText, 
  ChevronRight, 
  Play, 
  RotateCcw, 
  CheckCircle2, 
  Wand2,
  Layout,
  User,
  Zap,
  Globe
} from 'lucide-react';

// --- Curriculum Types ---
type Stage = 'Explain' | 'Demonstrate' | 'Imitate' | 'Practice';

interface Module {
  id: string;
  title: string;
  analogy: string;
  command: string;
  explain: string;
  demonstrate: string[];
  imitate: { prompt: string; target: string; }[];
  practice: { prompt: string; target: string; }[];
  proOutcome: string;
}

const MODULES: Module[] = [
  {
    id: 'navigation',
    title: 'Navigation',
    analogy: 'The Magic Map (pwd & ls)',
    command: 'ls',
    explain: 'The "ls" spell is like turning on the lights. It lets you see all the Toy Boxes (folders) in your current room.',
    demonstrate: ['pwd', 'ls', 'ls -l'],
    imitate: [{ prompt: 'Type exactly: ls', target: 'ls' }],
    practice: [{ prompt: 'Look inside the box: ls boxes', target: 'ls boxes' }],
    proOutcome: 'Proficient in POSIX-compliant filesystem traversal and hierarchical data management.'
  },
  {
    id: 'creation',
    title: 'Creation',
    analogy: 'The Building Spell (mkdir)',
    command: 'mkdir',
    explain: 'mkdir creates a brand new toy box. Just say the name, and it appears out of thin air!',
    demonstrate: ['mkdir castle', 'ls'],
    imitate: [{ prompt: 'Type exactly: mkdir my_box', target: 'mkdir my_box' }],
    practice: [{ prompt: 'Create a folder for "keys": mkdir keys', target: 'mkdir keys' }],
    proOutcome: 'Experienced in directory architecture design and environment bootstrapping.'
  }
];

export default function App() {
  const [moduleIndex, setModuleIndex] = useState(0);
  const [stage, setStage] = useState<Stage>('Explain');
  const [terminalHistory, setTerminalHistory] = useState<{user: boolean, text: string}[]>([]);
  const [inputValue, setInputValue] = useState('');
  const [isTyping, setIsTyping] = useState(false);
  const [completed, setCompleted] = useState<string[]>([]);
  const terminalRef = useRef<HTMLDivElement>(null);

  const currentModule = MODULES[moduleIndex];

  useEffect(() => {
    terminalRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [terminalHistory]);

  const handleCommand = (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputValue.trim()) return;

    const cmd = inputValue.trim();
    setTerminalHistory(prev => [...prev, { user: true, text: cmd }]);

    if (stage === 'Imitate' || stage === 'Practice') {
      const target = stage === 'Imitate' ? currentModule.imitate[0].target : currentModule.practice[0].target;
      if (cmd === target) {
        setTerminalHistory(prev => [...prev, { user: false, text: "✨ Magic Success! Quest Completed." }]);
        setTimeout(nextStep, 1000);
      } else {
        setTerminalHistory(prev => [...prev, { user: false, text: `❌ Oops! The spell requires: ${target}` }]);
      }
    } else {
      setTerminalHistory(prev => [...prev, { user: false, text: `Output: Running ${cmd}...` }]);
    }
    setInputValue('');
  };

  const nextStep = () => {
    if (stage === 'Explain') setStage('Demonstrate');
    else if (stage === 'Demonstrate') setStage('Imitate');
    else if (stage === 'Imitate') setStage('Practice');
    else {
      setCompleted(prev => [...new Set([...prev, currentModule.id])]);
      if (moduleIndex < MODULES.length - 1) {
        setModuleIndex(prev => prev + 1);
        setStage('Explain');
        setTerminalHistory([]);
      } else {
        alert("🎓 Academy Mastered!");
      }
    }
  };

  const runDemo = async () => {
    setIsTyping(true);
    setTerminalHistory([]);
    for (const cmd of currentModule.demonstrate) {
      setTerminalHistory(prev => [...prev, { user: true, text: cmd }]);
      await new Promise(r => setTimeout(r, 600));
      setTerminalHistory(prev => [...prev, { user: false, text: `Processing ${cmd}... Done.` }]);
      await new Promise(r => setTimeout(r, 600));
    }
    setIsTyping(false);
    nextStep();
  };

  return (
    <div className="min-h-screen bg-[#0F0F12] text-[#E0E0E6] font-sans selection:bg-[#7C3AED]/30 overflow-hidden flex flex-col">
      {/* Dynamic Header */}
      <header className="h-16 lg:h-20 bg-[#0F0F12] border-b border-white/10 px-6 flex items-center justify-between shrink-0">
        <div className="flex flex-col gap-0.5">
          <span className="text-[9px] uppercase tracking-[0.2em] text-[#7C3AED] font-bold">Mission: Linux Basic CLI</span>
          <h1 className="text-xl lg:text-3xl font-light tracking-tight">The Penguin's <span className="font-semibold text-white italic">Magic Spells</span></h1>
        </div>
        <div className="flex gap-4 lg:gap-12 items-center">
          <div className="text-right">
            <p className="text-[10px] uppercase opacity-40 mb-0.5">Energy Core</p>
            <p className="text-sm lg:text-lg font-mono text-white">{completed.length * 500} XP</p>
          </div>
          <div className="h-10 w-10 rounded-full bg-[#1A1A20] border border-white/10 flex items-center justify-center">
            <User className="w-5 h-5 opacity-40" />
          </div>
        </div>
      </header>

      {/* Main Grid Layout */}
      <main className="flex-1 grid grid-cols-12 gap-8 p-6 lg:p-8 min-h-0">
        {/* Left: Quest Control Panel (EDIP) */}
        <section className="col-span-12 lg:col-span-4 flex flex-col gap-6 overflow-hidden">
          <div className="bg-[#1A1A20] rounded-[2rem] p-8 border border-white/5 flex flex-col h-full shadow-2xl relative overflow-hidden">
            {/* Stage Badge */}
            <div className="flex items-center justify-between mb-8">
              <div className="flex items-center gap-3">
                <div className={`w-3 h-3 rounded-full ${stage === 'Explain' ? 'bg-[#7C3AED]' : stage === 'Demonstrate' ? 'bg-[#10B981]' : 'bg-amber-500'}`} />
                <h2 className="text-xl font-medium tracking-tight">Quest: <span className="text-[#7C3AED]">{currentModule.title}</span></h2>
              </div>
              <span className="bg-white/5 px-2 py-1 rounded text-[10px] font-bold tracking-widest text-white/40">{stage.toUpperCase()}</span>
            </div>

            <div className="flex-1 space-y-8 overflow-y-auto pr-2 scrollbar-hide">
              <div className="space-y-4">
                <p className="text-sm lg:text-base leading-relaxed text-[#A1A1AA]">
                  {stage === 'Explain' && currentModule.explain}
                  {stage === 'Imitate' && currentModule.imitate[0].prompt}
                  {stage === 'Practice' && currentModule.practice[0].prompt}
                  {stage === 'Demonstrate' && "Relax and watch the Wizard perform the spells on the map."}
                </p>
                
                <div className="bg-white/5 p-4 rounded-xl border border-white/5 italic text-sm text-[#7C3AED]">
                  "{currentModule.analogy}"
                </div>
              </div>
            </div>

            <div className="mt-8 pt-6 border-t border-white/5 flex flex-col gap-4">
              {stage === 'Explain' && (
                <button 
                  onClick={nextStep}
                  className="w-full py-4 bg-white text-black text-xs font-bold uppercase tracking-widest rounded-2xl hover:bg-slate-200 transition-all flex items-center justify-center gap-2"
                >
                  Confirm Insight <ChevronRight className="w-4 h-4" />
                </button>
              )}
              {stage === 'Demonstrate' && (
                <button 
                  onClick={runDemo}
                  disabled={isTyping}
                  className="w-full py-4 bg-[#7C3AED] text-white text-xs font-bold uppercase tracking-widest rounded-2xl hover:bg-[#6D28D9] disabled:opacity-50 transition-all flex items-center justify-center gap-2"
                >
                  <Play className="w-4 h-4 fill-current" /> Watch Magic
                </button>
              )}
              
              <div className="bg-[#2D2D35]/30 p-4 rounded-2xl border border-white/5 hidden lg:block">
                <p className="text-[10px] uppercase opacity-40 mb-1 tracking-widest font-bold">Resume Insight</p>
                <p className="text-[11px] text-white/50 leading-snug">
                  {completed.includes(currentModule.id) ? currentModule.proOutcome : "Complete module to unlock professional achievement."}
                </p>
              </div>
            </div>
          </div>
        </section>

        {/* Right: Xterm Terminal Simulator (Mobile Resized) */}
        <section className="col-span-12 lg:col-span-8 flex flex-col">
          <div className="flex-1 bg-[#050507] rounded-[2.5rem] border-[6px] border-[#1A1A20] shadow-[0_0_80px_-20px_rgba(124,58,237,0.4)] relative flex flex-col overflow-hidden">
            {/* Terminal Header */}
            <div className="h-14 bg-[#1A1A20]/50 border-b border-white/5 flex items-center justify-between px-8 relative">
              <div className="flex gap-2">
                <div className="w-2.5 h-2.5 rounded-full bg-[#333]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[#333]" />
                <div className="w-2.5 h-2.5 rounded-full bg-[#333]" />
              </div>
              <div className="flex items-center gap-3">
                <Globe className="w-3 h-3 opacity-20" />
                <span className="text-[10px] uppercase tracking-widest font-bold text-white/20">POSIX SIMULATOR V3.1</span>
              </div>
            </div>

            {/* Terminal Viewport */}
            <div className="flex-1 overflow-y-auto p-8 font-mono text-sm lg:text-base leading-relaxed scrollbar-hide">
              <div className="flex items-center gap-2 mb-6">
                <span className="text-[#7C3AED] text-[10px] font-bold bg-[#7C3AED]/10 px-2 py-1 rounded">BASH SHELL</span>
                <span className="text-white/10 text-[10px]">Wizard@Academy: ~ (zsh)</span>
              </div>

              {terminalHistory.map((line, i) => (
                <div key={i} className="mb-2 lg:mb-3 flex items-start gap-4">
                  <span className={line.user ? "text-[#10B981]" : "text-[#7C3AED] opacity-80"}>
                    {line.user ? "$" : "✨"}
                  </span>
                  <p className={`${line.user ? "text-white" : "text-[#A1A1AA] italic"} break-all`}>
                    {line.text}
                  </p>
                </div>
              ))}
              <div ref={terminalRef} />
            </div>

            {/* Terminal Input Line */}
            {(stage === 'Imitate' || stage === 'Practice') && (
              <div className="h-20 bg-[#050507] px-8 flex items-center border-t border-white/5">
                <form onSubmit={handleCommand} className="flex-1 flex items-center gap-4">
                  <span className="text-[#10B981] font-bold font-mono text-xl">$</span>
                  <input
                    type="text"
                    value={inputValue}
                    onChange={(e) => setInputValue(e.target.value)}
                    autoFocus
                    placeholder="Type magic here..."
                    className="flex-1 bg-transparent border-none text-white focus:ring-0 p-0 placeholder:text-white/5 font-mono text-lg"
                  />
                  <div className="w-2.5 h-7 bg-[#7C3AED] animate-blink" />
                </form>
              </div>
            )}
          </div>
          
          <div className="h-12 flex items-center justify-between px-6">
            <div className="flex gap-4 text-[9px] uppercase tracking-[0.2em] opacity-20 font-bold">
              <span>Android APK Ready</span>
              <span>PTY: /system/bin/sh</span>
            </div>
          </div>
        </section>
      </main>

      {/* Persistent Wizard Resume (Bottom Bar) */}
      <footer className="h-24 lg:h-32 bg-[#1A1A20]/40 border-t border-white/10 backdrop-blur-xl px-10 flex items-center gap-6 overflow-x-auto scrollbar-hide shrink-0">
        <div className="flex-none flex items-center gap-4 border-r border-white/10 pr-10">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-[#7C3AED] to-[#4C1D95] flex items-center justify-center shadow-lg shadow-purple-900/20">
            <FileText className="w-6 h-6 text-white" />
          </div>
          <div>
            <p className="text-xs font-bold uppercase tracking-widest">Active Resume</p>
            <p className="text-[10px] opacity-40">Translating magic to professional skills</p>
          </div>
        </div>
        
        <div className="flex gap-4">
          {completed.length === 0 && <p className="text-xs italic opacity-20">No achievements recorded yet.</p>}
          {completed.map(id => (
            <motion.div 
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              key={id} 
              className="px-6 py-3 bg-white/5 border border-white/5 rounded-2xl flex items-center gap-3 whitespace-nowrap"
            >
              <CheckCircle2 className="w-4 h-4 text-[#10B981]" />
              <div className="flex flex-col">
                <span className="text-[10px] font-bold text-white/40 uppercase tracking-tighter">Verified Skill</span>
                <span className="text-[11px] font-medium text-white/80">{MODULES.find(m => m.id === id)?.proOutcome}</span>
              </div>
            </motion.div>
          ))}
        </div>
      </footer>
    </div>
  );
}

