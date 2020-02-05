module ProcessHelper
  def setup_process(command, success, output)
    output_stub = double
    exit_code_stub = double
    handle_stub = double

    allow(handle_stub).to receive(:value).and_return(exit_code_stub)

    allow(output_stub).to receive(:gets).and_return(output, nil)
    allow(exit_code_stub).to receive(:success?).and_return(success)
    allow(Open3).to receive(:popen2e).with(command).and_yield(nil, output_stub, handle_stub)
  end
end