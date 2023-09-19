# frozen_string_literal: true

class GameRound
  TICKS_PER_GAME_TICK = 3
  LOOP_TICK_LENGTH = 0.12

  def self.call(logger:, **)
    games = Game.where(running: true)

    starting_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    games.each do |game|
      logger.debug("processing game #{game.id}")

      game.tick += 1

      logger.debug("-- registered actions #{game.actions.join(',')}")
      if game.actions.any?
        game.perform_registered_actions
        game.save!
      end

      if game.tick % TICKS_PER_GAME_TICK == 0
        if game.brick
          logger.debug("-- applying gravity")
          game.apply_gravity

          if game.question_result
            if game.question_tick < Game::QUESTION_ANSWER_VISIBILITY_TIME
              game.question_tick += 1
            else
              game.question_result = nil
            end
          end
        elsif game.question
          logger.debug("-- waiting for answer")
          game.question_tick += 1

          if game.question_tick == Game::QUESTION_VISIBILITY_TIME
            game.abandon_question

            logger.debug("-- spawning a new brick")
            game.spawn_brick
          end
        else
          logger.debug("-- removing full lines")
          game.handle_full_lines
        end

        game.save!
      end

      game.timer.save!
    end

    ending_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed_time = ending_time - starting_time

    if Flag.too_much_traffic?
      if elapsed_time < LOOP_TICK_LENGTH
        logger.debug("-- traffic is just fine at #{elapsed_time}s per tick")
        Flag.ok_traffic!
      end
    else
      if elapsed_time > LOOP_TICK_LENGTH
        logger.debug("-- too much traffic at #{elapsed_time}s per tick")
        Flag.too_much_traffic!
      end
    end
  end
end

namespace :game do
  desc 'Run Game'
  task start: :environment do
    RailsPermanentJob.jobs = [GameRound]
    RailsPermanentJob.after_job = ->(**_options) { sleep GameRound::LOOP_TICK_LENGTH }

    log_level = ENV['LOG_LEVEL'].presence || 'info'
    RailsPermanentJob.run(workers: 1, log_level: log_level)
  end
end
