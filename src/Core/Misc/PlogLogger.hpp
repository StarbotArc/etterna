#ifndef CORE_MISC_PLOGLOGGER_HPP
#define CORE_MISC_PLOGLOGGER_HPP

#include "Core/Services/ILogger.hpp"
#include <plog/Log.h>

#include <mutex>

class PlogLogger : public Core::ILogger {
public:
    int count = 0;
    Core::ILogger::Severity last_severity;
    std::string last_msg;
    std::mutex mutex;

    PlogLogger();
    void setLogLevel(ILogger::Severity logLevel) override;
	std::string getLogFile() override;
protected:
    void log(ILogger::Severity logLevel, const std::string_view message) override;
private:
  	std::string currentLogFile;

    static plog::Severity convertSeverity(Core::ILogger::Severity logLevel);
};

#endif //CORE_MISC_PLOGLOGGER_HPP
