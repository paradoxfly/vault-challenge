import { loadStdlib } from '@reach-sh/stdlib';
import * as backend from './build/index.main.mjs';
import { ask, yesno } from '@reach-sh/stdlib/ask.mjs';
const stdlib = loadStdlib(process.env);

const startingBalance = stdlib.parseCurrency(5000);
const acc = await stdlib.newTestAccount(startingBalance);

//Set up functions for checking balance
const fmt = (x) => stdlib.formatCurrency(x, 4);
const getBalance = async () => fmt(await stdlib.balanceOf(acc));

const before = await getBalance()
console.log('Your starting balance is: ' + before)
console.log(`Your address is ${acc.getAddress()}`)

const Shared = {
  viewTimer: (time) => {
    console.log(`Countdown time: ${parseInt(time)} network seconds`)
  },

  informTimeout: () => {
    console.log('There was a timeout')
  },

  checkBalance: async () => {
    console.log(`Your current balance is ${await getBalance()}`)
  }
}

const Alice = {
  ...Shared,

  stillHere: async () => {
    const here = await ask('Are you still here?', yesno)
    return here
  }
}

const Bob = {
  ...Shared,

  acceptTerms: async () => {
    const accept = await ask('Do you accept the terms?', yesno)
    if(accept){
      return accept
    }
    process.exit();
  }
}



const createStream = async () => {
  const isAlice = await ask(
    `Do you want to deploy the contract?`,
    yesno
  );
  const who = isAlice ? 'Alice' : 'Bob';

  console.log(`Starting as ${who}`);

  let ctc = null;
  if (isAlice) {
    ctc = acc.contract(backend);
    backend.Alice(ctc, Alice)
    console.log('Deploying Contract...');
    const info = JSON.stringify(await ctc.getInfo(), null, 2);
    console.log('Contract info..')
    console.log(info);
  } else {
    const info = await ask(
      `Please paste the contract information of the contract you want to attach to:`,
      JSON.parse
    );
    ctc = acc.contract(backend, info);
    backend.Bob(ctc, Bob);
    console.log("...Successfully Connected...")

    
  }
};

await createStream();