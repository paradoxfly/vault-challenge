'reach 0.1';
'use strict';

const Shared = {
  viewTimer: Fun([UInt], Null),
  informTimeout: Fun([], Null),
  checkBalance: Fun([], Null)
};

export const main =
  Reach.App(
    {
      untrustworthyMaps: true,
      connectors: [ALGO],
    },
    [Participant('Alice', {
      ...Shared,
      stillHere: Fun([], Bool)
    }),
    Participant('Bob', {
      ...Shared,
      acceptTerms: Fun([], Bool)
    })],
    (A, B) => {

      const informTimeout = () => {
        each([A, B], () => {
          interact.informTimeout();
          interact.checkBalance();
        });
      };

      const checkBalance = () => {
        each([A, B], () => {
          interact.checkBalance();
        });
      };

      const viewTimer = (time) => {
        each([A, B], () => {
          interact.viewTimer(time);
        });
      }

      const disburse = (here) => {
        if(here){
          transfer(balance()).to(A)
        }
        else {
          transfer(balance()).to(B)
        }
      }

      A.publish()
        .pay(3000000000); //3000 e6
      commit();

      const COUNTDOWN = 3;

      B.only(() => {
        const accepted = declassify(interact.acceptTerms())
      })
      B.publish(accepted);

      viewTimer(COUNTDOWN);

      const TERMINATION_TIME = lastConsensusTime() + COUNTDOWN;

      //While loop
      var [ shouldContinue, stillHere ] = [ true, true ];
      invariant(true == true);
      while(shouldContinue) {
        commit();

        A.only(() => {
          const here = declassify(interact.stillHere());
        });
        A.publish(here)
          .timeout(absoluteTime(TERMINATION_TIME), () => {
            B.publish();
            disburse(stillHere);
            informTimeout();
            commit();

            exit();
          });
        
        if((lastConsensusTime() == TERMINATION_TIME) || (lastConsensusTime() > TERMINATION_TIME)){
          [ shouldContinue, stillHere ] = [ false, here ];
          continue;
        }
        else {
          [ shouldContinue, stillHere ] = [ true, here ]
          continue;
        }
      }

      disburse(stillHere);
      checkBalance();

      commit();
      exit();
    });