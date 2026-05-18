export interface PracticeTask {
  description: string;
  targetState: string;
  expectedCommandPattern: string;
}

export interface Lesson {
  id: string;
  title: string;
  command: string;
  explanation: string;
  demonstrations: string[];
  imitations: string[];
  practices: PracticeTask[];
  skillEarned: string;
}

export const appLessons: Lesson[] = [
  {
    id: 'ls1',
    title: 'Module 1: Looking inside boxes',
    command: 'ls',
    explanation: 'The "ls" command is a magic spell to look inside your current folder, just like opening a toy box to see what toys are inside!',
    demonstrations: ['ls', 'ls -l', 'ls -a'],
    imitations: ['ls', 'ls -l', 'ls -a'],
    practices: [
      {
        description: 'Use the simple spell to list what is in your folder.',
        targetState: '',
        expectedCommandPattern: '^ls$',
      },
      {
        description: 'Try the spell that shows detailed information (like a long list).',
        targetState: '',
        expectedCommandPattern: '^ls \\-l$',
      },
      {
        description: 'Try the spell that shows even hidden toys (all items).',
        targetState: '',
        expectedCommandPattern: '^ls \\-a$',
      },
    ],
    skillEarned: 'Mastered inspecting directory contents with various options.',
  },
  {
    id: 'mkdir1',
    title: 'Module 2: Making new boxes',
    command: 'mkdir',
    explanation: 'The "mkdir" command makes a new directory (or folder). It stands for "make directory". Like building a new toy box!',
    demonstrations: ['mkdir toys', 'mkdir games', 'mkdir Secret_Club'],
    imitations: ['mkdir toys', 'mkdir games', 'mkdir Secret_Club'],
    practices: [
      {
        description: 'Create a new box called "MyStuff".',
        targetState: 'MyStuff_exists',
        expectedCommandPattern: '^mkdir MyStuff$',
      },
      {
        description: 'Create another box called "School".',
        targetState: 'School_exists',
        expectedCommandPattern: '^mkdir School$',
      },
      {
        description: 'Create a box called "Secret_Club" for you and your friends.',
        targetState: 'Secret_Club_exists',
        expectedCommandPattern: '^mkdir Secret_Club$',
      },
    ],
    skillEarned: 'Mastered hierarchical file system navigation and directory management.',
  },
  {
    id: 'pwd1',
    title: 'Module 3: Knowing where you are',
    command: 'pwd',
    explanation: 'The "pwd" command stands for "print working directory". It tells you exactly where you are in the magic file system!',
    demonstrations: ['pwd'],
    imitations: ['pwd'],
    practices: [
      {
        description: 'Cast the spell to find out your current path.',
        targetState: '',
        expectedCommandPattern: '^pwd$',
      }
    ],
    skillEarned: 'Command line spatial awareness safely orienting the user.',
  },
  {
    id: 'touch1',
    title: 'Module 4: Creating empty files',
    command: 'touch',
    explanation: 'The "touch" command is used to create new, empty files. Like summoning a blank scroll of parchment!',
    demonstrations: ['touch notes.txt', 'touch scroll.md'],
    imitations: ['touch paper.txt'],
    practices: [
      {
        description: 'Create a new file named "ideas.txt".',
        targetState: '',
        expectedCommandPattern: '^touch ideas\\.txt$',
      }
    ],
    skillEarned: 'Learned rapid file creation with touch.',
  },
  {
    id: 'rm1',
    title: 'Module 5: Removing files',
    command: 'rm',
    explanation: 'The "rm" command is a powerful spell to permanently delete files. Be careful, what is banished with rm is gone forever!',
    demonstrations: ['rm old_notes.txt'],
    imitations: ['rm unwanted.txt'],
    practices: [
      {
        description: 'Delete the file named "ideas.txt".',
        targetState: '',
        expectedCommandPattern: '^rm ideas\\.txt$',
      }
    ],
    skillEarned: 'Safe and deliberate file deletion tactics.',
  },
  {
    id: 'cat1',
    title: 'Module 6: Reading files',
    command: 'cat',
    explanation: 'The "cat" command is used to display the contents of a file directly in your terminal.',
    demonstrations: ['cat spell_book.txt'],
    imitations: ['cat spell_book.txt'],
    practices: [
      {
        description: 'Read the contents of "spell_book.txt".',
        targetState: '',
        expectedCommandPattern: '^cat spell_book\\.txt$',
      }
    ],
    skillEarned: 'Inspecting file contents without leaving the terminal context.',
  },
  {
    id: 'vi1',
    title: 'Module 7: Text Editor (vi)',
    command: 'vi',
    explanation: 'The "vi" command opens the default, ubiquitous Linux text editor. It lets you write and edit text inside a file directly from the terminal.',
    demonstrations: ['vi message.txt'],
    imitations: ['vi greeting.txt'],
    practices: [
      {
        description: 'Open a file named "my_notes.txt" with vi.',
        targetState: '',
        expectedCommandPattern: '^vi my_notes\\.txt$',
      }
    ],
    skillEarned: 'Proficient in initiating the vi text editor for file modification.',
  }
];
